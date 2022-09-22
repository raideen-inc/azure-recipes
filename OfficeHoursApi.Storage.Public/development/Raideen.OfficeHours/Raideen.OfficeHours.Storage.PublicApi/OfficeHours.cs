using Azure;
using Azure.Data.Tables;

namespace Raideen.OfficeHours.PublicApi
{
    public class OfficeHours : ITableEntity
    {
        public string PartitionKey { get; set; } = default!;
        
        public string RowKey { get; set; } = default!;

        public string Office { get; set; } = default!;

        public string Weekdays{ get; set; } = default!;

        public string Saturday { get; set; } = default!;

        public string Sunday { get; set; } = default!;

        public ETag ETag { get; set; } = default!;

        public DateTimeOffset? Timestamp { get; set; } = default!;
    }
}