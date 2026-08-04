using Core.DataAccess;
using Entities.Concrete;

namespace DataAccess.Abstract
{
    public interface IArticleDal : IEntityRepository<Article>
    {
        Task<List<Article>> GetArticlesWithCategoryAsync();
        Task<Article?> GetArticleDetailAsync(int id);
        Task IncrementViewCountAsync(int id);
        Task IncrementLikeCountAsync(int id);
    }
}
