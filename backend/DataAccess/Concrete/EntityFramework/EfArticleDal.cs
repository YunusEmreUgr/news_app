using Core.DataAccess.EntityFramework;
using DataAccess.Abstract;
using Entities.Concrete;
using Microsoft.EntityFrameworkCore;

namespace DataAccess.Concrete.EntityFramework
{
    public class EfArticleDal : EfEntityRepositoryBase<Article, AppDbContext>, IArticleDal
    {
        private readonly AppDbContext _context;

        public EfArticleDal(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<List<Article>> GetArticlesWithCategoryAsync()
        {
            return await _context.Articles
                .Include(a => a.Category)
                .OrderByDescending(a => a.PublishedAt)
                .ToListAsync();
        }

        public async Task<Article?> GetArticleDetailAsync(int id)
        {
            return await _context.Articles
                .Include(a => a.Category)
                .FirstOrDefaultAsync(a => a.Id == id);
        }

        public async Task IncrementViewCountAsync(int id)
        {
            var article = await _context.Articles.FindAsync(id);
            if (article != null)
            {
                article.ViewCount += 1;
                await _context.SaveChangesAsync();
            }
        }

        public async Task IncrementLikeCountAsync(int id)
        {
            var article = await _context.Articles.FindAsync(id);
            if (article != null)
            {
                article.LikeCount += 1;
                await _context.SaveChangesAsync();
            }
        }
    }
}
