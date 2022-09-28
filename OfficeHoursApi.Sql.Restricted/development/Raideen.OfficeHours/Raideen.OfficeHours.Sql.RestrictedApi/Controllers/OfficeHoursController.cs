using Microsoft.AspNetCore.Mvc;
using Raideen.OfficeHours.Sql.RestrictedApi.Data;
using System.Collections.Generic;

namespace Raideen.OfficeHours.Sql.RestrictedApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class OfficeHoursController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

        private readonly ILogger<OfficeHoursController> _logger;
        private readonly OfficeHoursContext _dbContext;

        public OfficeHoursController(ILogger<OfficeHoursController> logger, OfficeHoursContext dbContext)
        {
            _logger = logger;
            _dbContext = dbContext;
        }

        [HttpGet(Name = "GetWeatherForecast")]
        public IEnumerable<OfficeHour> Get()
        {
            return _dbContext.OfficeHours.ToList();
        }
    }
}