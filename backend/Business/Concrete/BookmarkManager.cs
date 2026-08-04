using Business.Abstract;
using Core.Utilities.Results;
using DataAccess.Abstract;
using Entities.Concrete;

namespace Business.Concrete
{
    public class BookmarkManager : IBookmarkService
    {
        private readonly IBookmarkDal _bookmarkDal;

        public BookmarkManager(IBookmarkDal bookmarkDal)
        {
            _bookmarkDal = bookmarkDal;
        }

        public async Task<IDataResult<List<Article>>> GetUserBookmarkedArticlesAsync(int userId)
        {
            var articles = await _bookmarkDal.GetUserBookmarkedArticlesAsync(userId);
            return new SuccessDataResult<List<Article>>(articles);
        }

        public async Task<IResult> ToggleBookmarkAsync(int userId, int articleId)
        {
            var existing = await _bookmarkDal.GetAsync(b => b.UserId == userId && b.ArticleId == articleId);
            if (existing != null)
            {
                await _bookmarkDal.DeleteAsync(existing);
                return new SuccessResult("Favorilerden çıkarıldı.");
            }
            else
            {
                await _bookmarkDal.AddAsync(new Bookmark
                {
                    UserId = userId,
                    ArticleId = articleId,
                    CreatedAt = DateTime.UtcNow
                });
                return new SuccessResult("Favorilere eklendi.");
            }
        }

        public async Task<IDataResult<bool>> IsBookmarkedAsync(int userId, int articleId)
        {
            var existing = await _bookmarkDal.GetAsync(b => b.UserId == userId && b.ArticleId == articleId);
            return new SuccessDataResult<bool>(existing != null);
        }
    }
}
