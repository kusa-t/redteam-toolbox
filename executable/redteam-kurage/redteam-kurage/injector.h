#pragma once

namespace Injector {
	BOOL hexToBytes(const char* hex, PBYTE buf, SIZE_T bufSize);
	BOOL RemoteMapInject(IN HANDLE hProcess, IN PBYTE pPayload, IN SIZE_T sPayloadSize, OUT PVOID* ppAddress);
}