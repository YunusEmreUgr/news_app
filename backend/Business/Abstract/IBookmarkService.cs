using Core.Utilities.Results;
using Entities.Concrete;

namespace Business.Abstract
{
    public interface IBookmarkService
    {
        Task<IDataResult<List<Article>>> GetUserBookmarkedArticlesAsync(int userId);
        Task<IResult> ToggleBookmarkAsync(int userId, int articleId);
        Task<IDataResult<bool>> IsBookmarkedAsync(int userId, int articleId);
    }
}
