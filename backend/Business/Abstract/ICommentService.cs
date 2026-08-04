using Core.Utilities.Results;
using Entities.Concrete;

namespace Business.Abstract
{
    public interface ICommentService
    {
        Task<IDataResult<List<Comment>>> GetByArticleIdAsync(int articleId);
        Task<IResult> AddAsync(Comment comment);
        Task<IResult> DeleteAsync(int id);
    }
}
