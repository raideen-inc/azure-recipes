using System;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Raideen.Invest.BusinessLogic.Data;
using Microsoft.EntityFrameworkCore;

namespace Raideen.Invest.Batch
{
    public class ProcessStockFunc
    {
        private readonly InvestContext investContext;

        public ProcessStockFunc(InvestContext dbContext)
        {
            this.investContext = dbContext;
        }

        [FunctionName("ProcessStockFuncBatch")]
        public async Task ProcessStockFuncBatch(
            [TimerTrigger("%CRON_BATCH_UPDATE%")] TimerInfo timer, ILogger log)
        {
            log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
            var stocks = await investContext.Stocks.ToListAsync();
        }

        [FunctionName("ProcessStockHttp")]
        public async Task<IActionResult> ProcessStockHttp([HttpTrigger(AuthorizationLevel.Anonymous, "get")]
            HttpRequest req, ILogger log)
        {
            log.LogInformation("Getting todo list items");
            var stocks = await investContext.Stocks.ToListAsync();
            return new OkObjectResult(stocks);
        }
    }
}
