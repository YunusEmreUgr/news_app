using Business.Abstract;
using Core.Utilities.Results;
using DataAccess.Abstract;
using Entities.Concrete;

namespace Business.Concrete
{
    public class CommentManager : ICommentService
    {
        private readonly ICommentDal _commentDal;

        public CommentManager(ICommentDal commentDal)
        {
            _commentDal = commentDal;
        }

        public async Task<IDataResult<List<Comment>>> GetByArticleIdAsync(int articleId)
        {
            var comments = await _commentDal.GetAllAsync(c => c.ArticleId == articleId && !c.IsDeleted);
            var sorted = comments.OrderByDescending(c => c.CreatedAt).ToList();
            return new SuccessDataResult<List<Comment>>(sorted);
        }

        public async Task<IResult> AddAsync(Comment comment)
        {
            comment.CreatedAt = DateTime.UtcNow;
            await _commentDal.AddAsync(comment);
            return new SuccessResult("Yorum eklendi.");
        }

        public async Task<IResult> DeleteAsync(int id)
        {
            var comment = await _commentDal.GetAsync(c => c.Id == id);
            if (comment != null)
            {
                comment.IsDeleted = true;
                await _commentDal.UpdateAsync(comment);
            }
            return new SuccessResult("Yorum silindi.");
        }
    }
}
