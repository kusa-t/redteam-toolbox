# Strategy

## Reconnaissance
### Port Scan
* nmap

## Initial Access
### HTTP
* File Upload
* SQL Injection
* OS Command Injection
* Server-Side Template Injection
* Vulnerable Software

### SMTP
* Collect Emails
* Phishing with Office
* Phishing with HTA

## Execution
### File Upload
* PHP -> upload obfuscated PHP Webshell
* ASPX -> upload obfuscated ASPX shellcode runner

### SQL Injection
* sqlmap to all inputs

### OS Command Injection
* try `|` ,`||`, `&&`, `;`

### Server-Side Template Injection
* Determine Template engine

### Phishing
* Office -> VBA shellcode runner with AMSI patching
* HTA -> HTA dropper for process injection

## Privilege Escalation
### Linux
* sudo
* SUID, SGID
* capabilities
* cron
* file permissions (`/etc/passwd`)
* linpeas
* pspy

### Windows
* SePrivileges
* Services
* Schtasks
* winPEAS
* PrivescCheck
* PowerSploit

## Persistence
### Linux
* SSH authorized_keys
* cron

### Windows
* Add exclusion path for Defender
* Add new user
* Enable RDP

### Pivot
* ligolo-ng

## Lateral Movement
### Linux
* Kerberos
* SSH private key
* SSH agent
* SSH control master
* Ansible

### Windows
* mimikatz
* winPEAS
* Autologon
* Powershell History
* SSH private key

### Active Directory
* BloodHound
* Kerberos tickets
* Kerberoast
* AS-REP roasting
* MSSQL Link server
* MSSQL UNC Path Injection
* Password Spray (AD Users, Administrator)
* SSH
* Web servrer

