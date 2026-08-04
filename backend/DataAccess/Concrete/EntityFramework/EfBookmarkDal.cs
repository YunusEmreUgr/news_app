using Core.DataAccess.EntityFramework;
using DataAccess.Abstract;
using Entities.Concrete;
using Microsoft.EntityFrameworkCore;

namespace DataAccess.Concrete.EntityFramework
{
    public class EfBookmarkDal : EfEntityRepositoryBase<Bookmark, AppDbContext>, IBookmarkDal
    {
        private readonly AppDbContext _context;

        public EfBookmarkDal(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<List<Article>> GetUserBookmarkedArticlesAsync(int userId)
        {
            return await _context.Bookmarks
                .Where(b => b.UserId == userId)
                .Include(b => b.Article)
                .ThenInclude(a => a!.Category)
                .Select(b => b.Article!)
                .Where(a => a != null)
                .ToListAsync();
        }
    }
}
