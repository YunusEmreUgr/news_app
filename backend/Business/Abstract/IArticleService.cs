using Core.Utilities.Results;
using Entities.Concrete;

namespace Business.Abstract
{
    public interface IArticleService
    {
        Task<IDataResult<List<Article>>> GetAllAsync();
        Task<IDataResult<List<Article>>> GetByCategoryAsync(int categoryId);
        Task<IDataResult<List<Article>>> GetBreakingNewsAsync();
        Task<IDataResult<List<Article>>> GetFeaturedNewsAsync();
        Task<IDataResult<List<Article>>> SearchAsync(string query);
        Task<IDataResult<Article>> GetByIdAsync(int id);
        Task<IResult> AddAsync(Article article);
        Task<IResult> UpdateAsync(Article article);
        Task<IResult> DeleteAsync(int id);
        Task<IResult> IncrementViewCountAsync(int id);
        Task<IResult> IncrementLikeCountAsync(int id);
    }
}
