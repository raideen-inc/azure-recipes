namespace Raideen.OfficeHours.Sql.RestrictedApi.Data
{
    public static class DbInitializer
    {
        public static void Initialize(OfficeHoursContext context)
        {
            context.Database.EnsureCreated();

            // Look for any students.
            if (context.OfficeHours.Any())
            {
                return;   // DB has been seeded
            }

            var officeHours = new OfficeHour[]
            {
                new OfficeHour{Region="GTA", Office="RH", Name="Raideen", Weekdays="9am to 5pm", Saturday="Closed", Sunday="Closed", LastModifiedDate=DateTime.Now}
            };

            foreach (OfficeHour item in officeHours)
            {
                context.OfficeHours.Add(item);
            }
            context.SaveChanges();
        }
    }
}
