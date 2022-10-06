using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using System;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;

namespace Raideen.Batch.Storage.Functions
{
    public class BatchDataUpdateFunc
    {
        // Useful links:
        // Examples:
        // -- https://github.com/Azure/azure-sdk-for-net/tree/main/sdk/storage/Microsoft.Azure.WebJobs.Extensions.Storage.Blobs#examples
        // Binding Expression:
        // -- https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-expressions-patterns#binding-expressions---app-settings
        // Connection parameter:
        // -- https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-storage-blob-output?tabs=in-process%2Cextensionv5&pivots=programming-language-csharp#connections
        // Default Storage with Managed Identity
        // -- https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=blob#connecting-to-host-storage-with-an-identity-preview

        // Http Trigger for quick test: [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
        // Timer Trigger: [TimerTrigger("0 */1 * * * *")]TimerInfo myTimer,
        [FunctionName("BatchDataUpdateFunc")]
        public static async Task Run(
            [TimerTrigger("%CRON_BATCH_UPDATE%")] TimerInfo timer,
            [Blob("%TARGET_FILE_NAME%", FileAccess.Write, Connection = "TARGET_STORAGE")] Stream outputBlob,
            ILogger log)
        {
            log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");

            string url = System.Environment.GetEnvironmentVariable("SOURCE_API_URL");

            HttpClient client = new HttpClient();
            HttpResponseMessage response = await client.GetAsync(url);
            if (response.IsSuccessStatusCode)
            {
                 outputBlob.Write(await response.Content.ReadAsByteArrayAsync());
            }
        }
    }
}
