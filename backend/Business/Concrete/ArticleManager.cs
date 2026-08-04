using Business.Abstract;
using Core.Aspects.Autofac.Caching;
using Core.Utilities.Results;
using DataAccess.Abstract;
using Entities.Concrete;

namespace Business.Concrete
{
    public class ArticleManager : IArticleService
    {
        private readonly IArticleDal _articleDal;

        public ArticleManager(IArticleDal articleDal)
        {
            _articleDal = articleDal;
        }

        [CacheAspect(duration: 10)]
        public async Task<IDataResult<List<Article>>> GetAllAsync()
        {
            var articles = await _articleDal.GetArticlesWithCategoryAsync();
            return new SuccessDataResult<List<Article>>(articles);
        }

        [CacheAspect(duration: 10)]
        public async Task<IDataResult<List<Article>>> GetByCategoryAsync(int categoryId)
        {
            var articles = await _articleDal.GetAllAsync(
                a => a.CategoryId == categoryId && !a.IsDeleted,
                a => a.Category!
            );
            var sorted = articles.OrderByDescending(a => a.PublishedAt).ToList();
            return new SuccessDataResult<List<Article>>(sorted);
        }

        [CacheAspect(duration: 5)]
        public async Task<IDataResult<List<Article>>> GetBreakingNewsAsync()
        {
            var articles = await _articleDal.GetAllAsync(
                a => a.IsBreaking && !a.IsDeleted,
                a => a.Category!
            );
            var sorted = articles.OrderByDescending(a => a.PublishedAt).ToList();
            return new SuccessDataResult<List<Article>>(sorted);
        }

        [CacheAspect(duration: 10)]
        public async Task<IDataResult<List<Article>>> GetFeaturedNewsAsync()
        {
            var articles = await _articleDal.GetAllAsync(
                a => a.IsFeatured && !a.IsDeleted,
                a => a.Category!
            );
            var sorted = articles.OrderByDescending(a => a.PublishedAt).ToList();
            return new SuccessDataResult<List<Article>>(sorted);
        }

        [CacheAspect(duration: 5)]
        public async Task<IDataResult<List<Article>>> SearchAsync(string query)
        {
            if (string.IsNullOrWhiteSpace(query))
                return await GetAllAsync();

            var lowerQuery = query.ToLower();
            var articles = await _articleDal.GetAllAsync(
                a => !a.IsDeleted && (a.Title.ToLower().Contains(lowerQuery) || a.Summary.ToLower().Contains(lowerQuery) || a.Content.ToLower().Contains(lowerQuery)),
                a => a.Category!
            );
            return new SuccessDataResult<List<Article>>(articles);
        }

        [CacheAspect(duration: 10)]
        public async Task<IDataResult<Article>> GetByIdAsync(int id)
        {
            var article = await _articleDal.GetArticleDetailAsync(id);
            if (article == null)
                return new ErrorDataResult<Article>("Haber bulunamadı.");

            return new SuccessDataResult<Article>(article);
        }

        [CacheRemoveAspect("IArticleService.Get")]
        public async Task<IResult> AddAsync(Article article)
        {
            article.CreatedAt = DateTime.UtcNow;
            article.PublishedAt = DateTime.UtcNow;
            await _articleDal.AddAsync(article);
            return new SuccessResult("Haber başarıyla eklendi.");
        }

        [CacheRemoveAspect("IArticleService.Get")]
        public async Task<IResult> UpdateAsync(Article article)
        {
            article.UpdatedAt = DateTime.UtcNow;
            await _articleDal.UpdateAsync(article);
            return new SuccessResult("Haber güncellendi.");
        }

        [CacheRemoveAspect("IArticleService.Get")]
        public async Task<IResult> DeleteAsync(int id)
        {
            var article = await _articleDal.GetAsync(a => a.Id == id);
            if (article != null)
            {
                article.IsDeleted = true;
                await _articleDal.UpdateAsync(article);
            }
            return new SuccessResult("Haber silindi.");
        }

        [CacheRemoveAspect("IArticleService.Get")]
        public async Task<IResult> IncrementViewCountAsync(int id)
        {
            await _articleDal.IncrementViewCountAsync(id);
            return new SuccessResult();
        }

        [CacheRemoveAspect("IArticleService.Get")]
        public async Task<IResult> IncrementLikeCountAsync(int id)
        {
            await _articleDal.IncrementLikeCountAsync(id);
            return new SuccessResult();
        }
    }
}
