using System;
using System.IO;
using System.Data;
using System.Configuration;
using Oracle.ManagedDataAccess.Client;

namespace ReportDB
{
    class Program
    {
        static void Main(string[] args)
        {
            string paramRep = null;
            if (args.Length == 0)
            {
                paramRep = ConfigurationManager.AppSettings["defaultParam"];
                if (String.IsNullOrEmpty(paramRep))
                    throw new ArgumentException("Parameter \'defaultParam\' cannot be null");
            }
            else
                paramRep = args[0];

            string outDir=ConfigurationManager.AppSettings["outdir"];
            if(String.IsNullOrEmpty(outDir))
                throw new ArgumentException("Parameter \'outdir\' cannot be null");

            string conStringUser = ConfigurationManager.ConnectionStrings["connection"].ConnectionString;            
            using (OracleConnection con = new OracleConnection(conStringUser))
            {
                using (OracleCommand cmd = con.CreateCommand())
                {
                    try
                    {
                        con.Open();
                        Console.WriteLine("Successfully connected to Oracle Database ");

                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandText = "SP_REP_EXPORT";
                        cmd.Parameters.Add("p_flusso", paramRep);
                        cmd.ExecuteNonQuery();
                        Console.WriteLine("Successfully Execute Command");

                        cmd.CommandType = CommandType.Text;
                        cmd.Parameters.Clear();
                        cmd.CommandText = "SELECT * FROM REPORT_EXPORT WHERE FLUSSO = :p_flusso ORDER BY 2";
                        cmd.Parameters.Add("p_flusso", paramRep);
                        cmd.ExecuteNonQuery();

                        OracleDataReader reader = cmd.ExecuteReader();
                        Console.WriteLine("Successfully Execute Query");

                        //current PROJECT directory
                        string filename = paramRep + " " + DateTime.Now.ToString("dd-mm-yyyy-HH-mm-ss") + ".csv";                        
                        string projDir = Environment.CurrentDirectory;
                        
                        if (!Directory.Exists(Path.Combine(projDir, outDir)))
                            Directory.CreateDirectory(Path.Combine(projDir, outDir));

                        int recordNum = 0;
                        using (StreamWriter outputFile = new StreamWriter(Path.Combine(projDir, outDir, filename)))
                        {
                            while (reader.Read())
                            {
                                recordNum++;
                                outputFile.WriteLine(reader.GetString(2));
                            }
                        }

                        reader.Dispose();
                        Console.WriteLine("File Created, total written records: " + recordNum );
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.Message);
                    }
                }
            }
        }
    }
}