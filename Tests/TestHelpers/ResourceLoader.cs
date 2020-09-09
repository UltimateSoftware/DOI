using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.TestHelpers
{
    public static class ResourceLoader
    {
        public static string Load(string fileName)
        {
            using (Stream s = GetResourceStreamByFullyQualifiedFileName(fileName, Assembly.GetCallingAssembly()))
            {
                using (StreamReader sr = new StreamReader(s))
                {
                    return sr.ReadToEnd();
                }
            }
        }

        public static byte[] LoadBytes(string fileName)
        {
            using (Stream s = GetResourceStreamByFullyQualifiedFileName(fileName, Assembly.GetCallingAssembly()))
            {
                using (BinaryReader br = new BinaryReader(s))
                {
                    return br.ReadBytes((int)s.Length);
                }
            }
        }

        public static Stream LoadStream(string fileName)
        {
            return GetResourceStreamByFullyQualifiedFileName(fileName, Assembly.GetCallingAssembly());
        }

        public static string GetFullResourceFilePath(string fileName)
        {
            if (string.IsNullOrEmpty(fileName))
            {
                throw new ArgumentNullException(nameof(fileName));
            }

            Assembly assembly = Assembly.GetCallingAssembly();

            Uri assemblyUri = new Uri(assembly.CodeBase);

            if (!assemblyUri.IsFile)
            {
                throw new Exception("The resource file can't be located");
            }

            string directory = Path.GetDirectoryName(assemblyUri.AbsolutePath);

            string path = Path.Combine(directory, "Resources", fileName);
            if (!File.Exists(path))
            {
                throw new Exception("Resource File doesn't exists");
            }

            return path;
        }

        private static Stream GetResourceStreamByFullyQualifiedFileName(string fileName, Assembly fromAssembly)
        {
            if (string.IsNullOrEmpty(fileName))
            {
                throw new ArgumentNullException(nameof(fileName));
            }

            string[] resourceNames = fromAssembly.GetManifestResourceNames();

            string fullyQualifiedFileName = (from a in resourceNames
                where a.Trim().ToUpper().EndsWith("." + fileName.Trim().ToUpper())
                select a).FirstOrDefault();

            if (string.IsNullOrEmpty(fullyQualifiedFileName))
            {
                throw new FileLoadException($"File {fileName} not found in assembly {fromAssembly.FullName}.");
            }

            return fromAssembly.GetManifestResourceStream(fullyQualifiedFileName);
        }
    }
}