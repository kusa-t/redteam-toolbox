# Web

## Reconnaissance

### Architecture
* framework
* language
* middleware
* database
* template engine
* OSS
* API


### Crawling
* list path, parameters

### Directory Bruteforce
```bash
gobuster dir -u <url> -w /usr/share/seclists/Discovery/Web-Content/common.txt 
```

## Execution
### File Upload
* ASPX
1. upload `runner/shellcode.aspx`
2. access the uploaded aspx file
3. submit shellcode in hex

* PHP
1. upload `webshell/shell.php`
2. access the uploaded php file with `cmd` parameter

* Others
upload pe or office file.target user may open it.

### SQL Injection
* Error-Based
* Time-Based
* Automation
```bash
sqlmap -u "<url>" --os-shell
```

### OS Command Injection
* try `|` ,`||`, `&&`, `;`


### Server-Side Template Injection
* Razor
```razor
@(4*4)
@System.Diagnostics.Process.Start("cmd.exe","/c <command>");
```

