using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Raideen.Invest.BusinessLogic;
using Raideen.Invest.BusinessLogic.Data;

namespace Raideen.Invest.Web.Pages.Stocks
{
    public class IndexModel : PageModel
    {
        private readonly InvestContext _context;

        public IndexModel(InvestContext context)
        {
            _context = context;
        }

        public IList<Stock> Stock { get;set; } = default!;

        public async Task OnGetAsync()
        {
            if (_context.Stocks != null)
            {
                Stock = await _context.Stocks.ToListAsync();
            }
        }
    }
}
