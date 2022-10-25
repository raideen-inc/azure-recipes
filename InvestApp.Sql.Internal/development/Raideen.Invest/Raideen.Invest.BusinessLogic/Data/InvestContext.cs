using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Raideen.Invest.BusinessLogic.Data
{ 
    public class InvestContext : DbContext
    {
        public InvestContext(DbContextOptions<InvestContext> options) : base(options)
        {
        }

        // See: https://docs.microsoft.com/en-us/ef/core/miscellaneous/nullable-reference-types#non-nullable-properties-and-initialization
        public DbSet<Stock> Stocks { get; set; } = default!;
    }
}
