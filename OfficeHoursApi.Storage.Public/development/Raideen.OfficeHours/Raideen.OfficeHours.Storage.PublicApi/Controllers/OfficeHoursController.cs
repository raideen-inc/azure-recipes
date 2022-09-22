using Azure.Data.Tables;
using Azure.Identity;
using Microsoft.AspNetCore.Mvc;

namespace Raideen.OfficeHours.PublicApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class OfficeHoursController : ControllerBase
    {
        private readonly ILogger<OfficeHoursController> _logger;

        public OfficeHoursController(ILogger<OfficeHoursController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetOfficeHours")]
        public IEnumerable<OfficeHours> Get()
        {
            //TableServiceClient tableServiceClient = new TableServiceClient(Environment.GetEnvironmentVariable("STORAGE_TABLE_CONNSTRING"));
            //TableClient tableClient = tableServiceClient.GetTableClient(tableName: "OfficeHours");

            string? connString = Environment.GetEnvironmentVariable("STORAGE_TABLE_CONNSTRING");

            if (String.IsNullOrEmpty(connString))
            {
                throw new Exception("Connection String not configured for Storage Account");
            }
            TableClient tableClient = new TableClient(new Uri(connString), "OfficeHours", new DefaultAzureCredential());
            tableClient.CreateIfNotExists();
            var hours = tableClient.Query<OfficeHours>().ToList();

            hours.Add(new OfficeHours { Office = "Test" });

            return hours;
        }
    }
}