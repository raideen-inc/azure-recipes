using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Raideen.Invest.BusinessLogic.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

string? connString = builder.Configuration["AZURE_SQL_CONNECTIONSTRING"];
if (String.IsNullOrEmpty(connString))
{
    throw new Exception("Connection String not configured for SQL database");
}
builder.Services.AddDbContext<InvestContext>(options => options.UseSqlServer(connString));

var app = builder.Build();

var serviceScopeFactory = app.Services.GetService<IServiceScopeFactory>()!;
using (var scope = serviceScopeFactory.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetService<InvestContext>()!;
    DbInitializer.Initialize(dbContext);
}

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();

app.Run();
