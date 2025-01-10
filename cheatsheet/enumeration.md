# Enumeration

## Port Scan
```
nmap -Pn -p0-65535 192.168.1.1
nmap -Pn -sC -sV -p <ports> 192.168.1.1
```

## HTTP
```
gobuster dir -u <url> -w <wordlist> -x <extension> -b <blacklist>
```