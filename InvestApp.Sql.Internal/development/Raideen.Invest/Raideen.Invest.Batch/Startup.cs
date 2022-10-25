using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Raideen.Invest.BusinessLogic.Data;
using System;

[assembly: FunctionsStartup(typeof(Raideen.Invest.Batch.Startup))]
namespace Raideen.Invest.Batch
{
    class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            FunctionsHostBuilderContext context = builder.GetContext();

            string connString = Environment.GetEnvironmentVariable("AZURE_SQL_CONNECTIONSTRING");
            if (String.IsNullOrEmpty(connString))
            {
                throw new Exception("Connection String not configured for SQL database");
            }
            builder.Services.AddDbContext<InvestContext>(
                options => SqlServerDbContextOptionsExtensions.UseSqlServer(options, connString));
        }
    }
}
