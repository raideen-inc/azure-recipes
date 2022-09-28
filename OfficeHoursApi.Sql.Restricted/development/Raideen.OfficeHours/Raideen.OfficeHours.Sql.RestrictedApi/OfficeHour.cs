using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace Raideen.OfficeHours.Sql.RestrictedApi
{
    public class OfficeHour
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        public string Region { get; set; } = default!;

        public string Office { get; set; } = default!;

        public string Name { get; set; } = default!;

        public string Weekdays { get; set; } = default!;

        public string Saturday { get; set; } = default!;

        public string Sunday { get; set; } = default!;

        public DateTimeOffset? LastModifiedDate { get; set; } = default!;
    }
}