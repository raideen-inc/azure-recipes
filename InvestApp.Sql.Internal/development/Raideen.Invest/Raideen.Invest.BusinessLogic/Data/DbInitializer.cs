using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Raideen.Invest.BusinessLogic.Data
{
    public static class DbInitializer
    {
        public static void Initialize(InvestContext context)
        {
            context.Database.EnsureCreated();

            // Look for any profolio.
            if (context.Stocks.Any())
            {
                return;   // DB has been seeded
            }

            var stocks = new Stock[]
            {
                new Stock { Market = "NASDAQ", Symbol = "MSFT", Name = "Microsoft" },
                new Stock { Market = "NASDAQ", Symbol = "NFLX", Name = "Netflix"},
                new Stock { Market = "NYSE", Symbol = "BAC", Name = "Bank of America"}
            };


            foreach (Stock item in stocks)
            {
                context.Stocks.Add(item);
            }
            context.SaveChanges();
        }
    }
}
