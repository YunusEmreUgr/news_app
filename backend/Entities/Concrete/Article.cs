using Core.Entities.Abstract;
using System.ComponentModel.DataAnnotations.Schema;

namespace Entities.Concrete
{
    [Table("articles")]
    public class Article : IEntity
    {
        [Column("id")]
        public int Id { get; set; }

        [Column("title")]
        public string Title { get; set; } = string.Empty;

        [Column("summary")]
        public string Summary { get; set; } = string.Empty;

        [Column("content")]
        public string Content { get; set; } = string.Empty;

        [Column("cover_image_url")]
        public string? CoverImageUrl { get; set; }

        [Column("category_id")]
        public int CategoryId { get; set; }

        [Column("author_name")]
        public string AuthorName { get; set; } = "Haberim Editörü";

        [Column("view_count")]
        public int ViewCount { get; set; } = 0;

        [Column("like_count")]
        public int LikeCount { get; set; } = 0;

        [Column("is_breaking")]
        public bool IsBreaking { get; set; } = false;

        [Column("is_featured")]
        public bool IsFeatured { get; set; } = false;

        [Column("published_at")]
        public DateTime PublishedAt { get; set; } = DateTime.UtcNow;

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }

        [Column("is_deleted")]
        public bool IsDeleted { get; set; } = false;

        public virtual Category? Category { get; set; }
    }
}
