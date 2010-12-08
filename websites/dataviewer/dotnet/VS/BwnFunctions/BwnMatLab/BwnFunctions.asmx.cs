using System.IO;
using System.Web.Services;
using MathWorks.MATLAB.NET.Arrays;

namespace BwnMatLab
{
    /// <summary>
    /// Summary description for BwnFunctionsWrapper
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class BwnFunctionsWrapper : WebService
    {
        private const string OutputDir = "/Output/";
        private readonly string outputPath;
        private readonly BwnFunctions.BwnFunctions libraryInitializor = new BwnFunctions.BwnFunctions();

        public BwnFunctionsWrapper()
        {
            outputPath = Server.MapPath("~") + OutputDir ;
            libraryInitializor.Initialize();
            if (!Directory.Exists(outputPath))
            {
                Directory.CreateDirectory(outputPath);
            }
        }

        [WebMethod]
        public string InterpolateToLine(string ncFilePath, string ncVariableName, double centreLatitude, double centreLongitude, double vertexLatitude, double vertexLongitude)
        {
            var fullFilePath = libraryInitializor.InterpolateToLine(
                ncFilePath, ncVariableName, 
                new MWNumericArray(new[] {centreLatitude, centreLongitude}),
                new MWNumericArray(new[] {vertexLatitude, vertexLongitude}),
                outputPath).ToString();

            return OutputDir + Path.GetFileName(fullFilePath);
        }

        [WebMethod]
        public string PlotTimeSeries(string ncFilePath, string ncVariableName)
        {
            var fullFilePath =libraryInitializor.PlotTimeSeries(ncFilePath,ncVariableName, 
                outputPath).ToString();
            return OutputDir + Path.GetFileName(fullFilePath);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                libraryInitializor.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
