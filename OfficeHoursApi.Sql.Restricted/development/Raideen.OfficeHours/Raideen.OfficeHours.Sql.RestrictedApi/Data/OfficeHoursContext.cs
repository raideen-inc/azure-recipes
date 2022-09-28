using Microsoft.EntityFrameworkCore;

namespace Raideen.OfficeHours.Sql.RestrictedApi.Data
{
    public class OfficeHoursContext : DbContext
    {
        public OfficeHoursContext(DbContextOptions<OfficeHoursContext> options) : base(options)
        {
        }

        // See: https://docs.microsoft.com/en-us/ef/core/miscellaneous/nullable-reference-types#non-nullable-properties-and-initialization
        public DbSet<OfficeHour> OfficeHours => Set<OfficeHour>();
    }
}
