using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNet.Mvc;
using Microsoft.Extensions.Configuration;
using System.Text;
using System.Collections;

namespace DockerEnvDemo.Controllers
{
    public class HomeController : Controller
    {
        private IConfiguration _config;

        public HomeController(IConfiguration config)
        {
            _config = config;
        }
        public IActionResult Index()
        {
            return View();
        }

        public IActionResult About()
        {
            //var value = _config.GetSection("Foo").GetSection("Bar").Value;
            StringBuilder envVars = new StringBuilder();
            foreach (DictionaryEntry de in Environment.GetEnvironmentVariables())
                envVars.Append((string)de.Key + ":" + (string)de.Value + "---" + Environment.NewLine);

            ViewData["EnvVars"] = envVars.ToString();
            ViewData["HostName"] = (Environment.GetEnvironmentVariables()["HOSTNAME"] != null) ?
                Environment.GetEnvironmentVariables()["HOSTNAME"] :
                Environment.GetEnvironmentVariables()["COMPUTERNAME"];
            var os = Environment.GetEnvironmentVariables()["DNX_RUNTIME_ID"];
            ViewData["CheckPoint"] = "DNX_RUNTIME_ID";
            if (os == null)
            {
                os = Environment.GetEnvironmentVariable("OS");
                ViewData["CheckPoint"] = "GetEnvironmentVariable(OS)";
            }
            ViewData["OS"] = os;
            ViewData["PROCESSOR_ARCHITEW6432"] = Environment.GetEnvironmentVariable("PROCESSOR_ARCHITEW6432");
            ViewData["CheckPoint"] = "GetEnvironmentVariable(POCESSOR_ARCHITEW6432)";
            ViewData["ASPNET_Env"] = Environment.GetEnvironmentVariable("Hosting:Environment");


            ViewData["ImageStorageContainer"] = _config.Get<string>("ImageStorageContainer");
            ViewData["AuthDatabase"] = _config.Get<string>("AuthDatabase");
            ViewData["AppInsightsKey"] = _config.Get<string>("AppInsightsKey");
            ViewData["CheckPoint"] = "Done";
            return View();
        }

        public IActionResult Contact()
        {
            ViewData["Message"] = "Your contact page.";

            return View();
        }

        public IActionResult Error()
        {
            return View();
        }
    }
}
