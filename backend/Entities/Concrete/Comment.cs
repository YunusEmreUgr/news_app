using Core.Entities.Abstract;
using System.ComponentModel.DataAnnotations.Schema;

namespace Entities.Concrete
{
    [Table("comments")]
    public class Comment : IEntity
    {
        [Column("id")]
        public int Id { get; set; }

        [Column("article_id")]
        public int ArticleId { get; set; }

        [Column("user_name")]
        public string UserName { get; set; } = string.Empty;

        [Column("content")]
        public string Content { get; set; } = string.Empty;

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("is_deleted")]
        public bool IsDeleted { get; set; } = false;

        public virtual Article? Article { get; set; }
    }
}
