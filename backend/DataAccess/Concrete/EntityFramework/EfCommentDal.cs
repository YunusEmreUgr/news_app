using Core.DataAccess.EntityFramework;
using DataAccess.Abstract;
using Entities.Concrete;

namespace DataAccess.Concrete.EntityFramework
{
    public class EfCommentDal : EfEntityRepositoryBase<Comment, AppDbContext>, ICommentDal
    {
        public EfCommentDal(AppDbContext context) : base(context)
        {
        }
    }
}
