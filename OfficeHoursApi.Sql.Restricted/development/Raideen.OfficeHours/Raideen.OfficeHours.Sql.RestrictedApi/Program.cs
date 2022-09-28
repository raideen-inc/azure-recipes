using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;
using Raideen.OfficeHours.Sql.RestrictedApi.Data;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Setup DB Context
string? connString = builder.Configuration["AZURE_SQL_CONNECTIONSTRING"];
if (String.IsNullOrEmpty(connString))
{
    throw new Exception("Connection String not configured for SQL database");
}
builder.Services.AddDbContext<OfficeHoursContext>(options => options.UseSqlServer(connString));

var app = builder.Build();

var serviceScopeFactory = app.Services.GetService<IServiceScopeFactory>()!;
using (var scope = serviceScopeFactory.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetService<OfficeHoursContext>()!;
    DbInitializer.Initialize(dbContext);
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();

