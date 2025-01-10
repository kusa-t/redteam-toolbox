using System;
using System.Runtime.ConstrainedExecution;
using System.Runtime.InteropServices;
using System.Security;

namespace Yadokari
{
    class Native
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr CreateFileMapping(IntPtr hFile,
           IntPtr lpFileMappingAttributes, uint flProtect, uint dwMaximumSizeHigh,
           uint dwMaximumSizeLow, string lpName);
        [DllImport("kernel32.dll")]
        public static extern IntPtr MapViewOfFile(IntPtr hFileMappingObject,
           uint dwDesiredAccess, uint dwFileOffsetHigh, uint dwFileOffsetLow,
           uint dwNumberOfBytesToMap);
        [DllImport("kernelbase.dll", SetLastError = true)]
        public static extern IntPtr MapViewOfFileNuma2(
            IntPtr FileMappingHandle,
            IntPtr ProcessHandle,
            UInt64 Offset,
            IntPtr BaseAddress,
            int ViewSize,
            UInt32 AllocationType,
            UInt32 PageProtection,
            UInt32 Numa);
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr GetCurrentProcess();

        [DllImport("kernel32.dll", SetLastError = true)]
        [ReliabilityContract(Consistency.WillNotCorruptState, Cer.Success)]
        [SuppressUnmanagedCodeSecurity]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool CloseHandle(IntPtr hObject);

        [DllImport("kernel32.dll")]
        public static extern IntPtr CreateThread(IntPtr lpThreadAttributes,
            uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter,
                  uint dwCreationFlags, IntPtr lpThreadId);

        [DllImport("kernel32.dll")]
        public static extern UInt32 WaitForSingleObject(IntPtr hHandle,
            UInt32 dwMilliseconds);
    }
}
