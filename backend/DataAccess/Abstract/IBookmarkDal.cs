using Core.DataAccess;
using Entities.Concrete;

namespace DataAccess.Abstract
{
    public interface IBookmarkDal : IEntityRepository<Bookmark>
    {
        Task<List<Article>> GetUserBookmarkedArticlesAsync(int userId);
    }
}
