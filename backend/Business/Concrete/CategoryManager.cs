using Business.Abstract;
using Core.Utilities.Results;
using DataAccess.Abstract;
using Entities.Concrete;

namespace Business.Concrete
{
    public class CategoryManager : ICategoryService
    {
        private readonly ICategoryDal _categoryDal;

        public CategoryManager(ICategoryDal categoryDal)
        {
            _categoryDal = categoryDal;
        }

        public async Task<IDataResult<List<Category>>> GetAllAsync()
        {
            var categories = await _categoryDal.GetAllAsync(c => !c.IsDeleted);
            return new SuccessDataResult<List<Category>>(categories);
        }

        public async Task<IDataResult<Category>> GetByIdAsync(int id)
        {
            var category = await _categoryDal.GetAsync(c => c.Id == id && !c.IsDeleted);
            if (category == null)
                return new ErrorDataResult<Category>("Kategori bulunamadı.");

            return new SuccessDataResult<Category>(category);
        }

        public async Task<IDataResult<Category>> GetBySlugAsync(string slug)
        {
            var category = await _categoryDal.GetAsync(c => c.Slug == slug && !c.IsDeleted);
            if (category == null)
                return new ErrorDataResult<Category>("Kategori bulunamadı.");

            return new SuccessDataResult<Category>(category);
        }

        public async Task<IResult> AddAsync(Category category)
        {
            await _categoryDal.AddAsync(category);
            return new SuccessResult("Kategori başarıyla eklendi.");
        }

        public async Task<IResult> UpdateAsync(Category category)
        {
            await _categoryDal.UpdateAsync(category);
            return new SuccessResult("Kategori başarıyla güncellendi.");
        }

        public async Task<IResult> DeleteAsync(int id)
        {
            var category = await _categoryDal.GetAsync(c => c.Id == id);
            if (category != null)
            {
                category.IsDeleted = true;
                await _categoryDal.UpdateAsync(category);
            }
            return new SuccessResult("Kategori silindi.");
        }
    }
}
