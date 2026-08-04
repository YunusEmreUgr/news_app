using Core.Entities.Concrete.Users;
using Core.Utilities.Security.Hashing;
using Entities.Concrete;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace DataAccess.Concrete.EntityFramework.Seed
{
    public static class DbSeeder
    {
        public static async Task SeedAsync(AppDbContext context)
        {
            try
            {
                var pendingMigrations = await context.Database.GetPendingMigrationsAsync();
                if (pendingMigrations.Any())
                {
                    await context.Database.MigrateAsync();
                }
            }
            catch
            {
                // EnsureCreated fallback
            }

            // ─── 1. Users Seeding ─────────────────────────────────────────────
            if (!await context.Users.AnyAsync())
            {
                HashingHelper.CreatePasswordHash("Admin123!", out var adminHash, out var adminSalt);
                HashingHelper.CreatePasswordHash("User123!", out var userHash, out var userSalt);
                HashingHelper.CreatePasswordHash("Editor123!", out var editorHash, out var editorSalt);

                var users = new[]
                {
                    new User
                    {
                        FirstName = "Admin",
                        LastName = "Yönetici",
                        Email = "admin@template.com",
                        PasswordHash = adminHash,
                        PasswordSalt = adminSalt,
                        EmailConfirmed = true,
                        Status = true,
                        CreatedAt = DateTime.UtcNow
                    },
                    new User
                    {
                        FirstName = "Ahmet",
                        LastName = "Yılmaz",
                        Email = "editor@haberim.com",
                        PasswordHash = editorHash,
                        PasswordSalt = editorSalt,
                        EmailConfirmed = true,
                        Status = true,
                        CreatedAt = DateTime.UtcNow
                    },
                    new User
                    {
                        FirstName = "Okur",
                        LastName = "Kullanıcı",
                        Email = "user@haberim.com",
                        PasswordHash = userHash,
                        PasswordSalt = userSalt,
                        EmailConfirmed = true,
                        Status = true,
                        CreatedAt = DateTime.UtcNow
                    }
                };

                await context.Users.AddRangeAsync(users);
                await context.SaveChangesAsync();
            }

            // ─── 2. OperationClaims Seeding ───────────────────────────────────
            if (!await context.OperationClaims.AnyAsync())
            {
                var claims = new[]
                {
                    new OperationClaim { OperationClaimName = "Admin" },
                    new OperationClaim { OperationClaimName = "Publisher" },
                    new OperationClaim { OperationClaimName = "User" }
                };

                await context.OperationClaims.AddRangeAsync(claims);
                await context.SaveChangesAsync();
            }

            // ─── 3. UserOperationClaims Seeding ───────────────────────────────
            if (!await context.UserOperationClaims.AnyAsync())
            {
                var adminUser = await context.Users.FirstOrDefaultAsync(u => u.Email == "admin@template.com");
                var editorUser = await context.Users.FirstOrDefaultAsync(u => u.Email == "editor@haberim.com");
                var normalUser = await context.Users.FirstOrDefaultAsync(u => u.Email == "user@haberim.com");

                var adminClaim = await context.OperationClaims.FirstOrDefaultAsync(c => c.OperationClaimName == "Admin");
                var publisherClaim = await context.OperationClaims.FirstOrDefaultAsync(c => c.OperationClaimName == "Publisher");
                var userClaim = await context.OperationClaims.FirstOrDefaultAsync(c => c.OperationClaimName == "User");

                var userClaims = new List<UserOperationClaim>();

                if (adminUser != null && adminClaim != null)
                    userClaims.Add(new UserOperationClaim { UserId = adminUser.UserId, OperationClaimId = adminClaim.OperationClaimId });
                if (adminUser != null && publisherClaim != null)
                    userClaims.Add(new UserOperationClaim { UserId = adminUser.UserId, OperationClaimId = publisherClaim.OperationClaimId });
                if (adminUser != null && userClaim != null)
                    userClaims.Add(new UserOperationClaim { UserId = adminUser.UserId, OperationClaimId = userClaim.OperationClaimId });

                if (editorUser != null && publisherClaim != null)
                    userClaims.Add(new UserOperationClaim { UserId = editorUser.UserId, OperationClaimId = publisherClaim.OperationClaimId });
                if (editorUser != null && userClaim != null)
                    userClaims.Add(new UserOperationClaim { UserId = editorUser.UserId, OperationClaimId = userClaim.OperationClaimId });

                if (normalUser != null && userClaim != null)
                    userClaims.Add(new UserOperationClaim { UserId = normalUser.UserId, OperationClaimId = userClaim.OperationClaimId });

                if (userClaims.Count > 0)
                {
                    await context.UserOperationClaims.AddRangeAsync(userClaims);
                    await context.SaveChangesAsync();
                }
            }

            // ─── 4. Categories Seeding ────────────────────────────────────────
            if (!await context.Categories.AnyAsync())
            {
                var categories = new[]
                {
                    new Category { Name = "Gündem", Slug = "gundem", Icon = "newspaper", Description = "Türkiye ve dünyadan en son haberler" },
                    new Category { Name = "Teknoloji", Slug = "teknoloji", Icon = "cpu", Description = "Yapay zeka, akıllı telefonlar ve teknoloji dünyası" },
                    new Category { Name = "Spor", Slug = "spor", Icon = "trophy", Description = "Futbol, basketbol ve tüm spor dünyasındaki gelişmeler" },
                    new Category { Name = "Ekonomi", Slug = "ekonomi", Icon = "trending_up", Description = "Piyasalar, borsa, döviz ve finans dünyası" },
                    new Category { Name = "Dünya", Slug = "dunya", Icon = "globe", Description = "Uluslararası ilişkiler ve küresel gelişmeler" },
                    new Category { Name = "Kültür & Sanat", Slug = "kultur-sanat", Icon = "palette", Description = "Sinema, tiyatro, kitap ve sanat haberleri" },
                    new Category { Name = "Sağlık", Slug = "saglik", Icon = "health_and_safety", Description = "Sağlık haberleri ve tıbbi gelişmeler" },
                    new Category { Name = "Otomobil", Slug = "otomobil", Icon = "directions_car", Description = "Otomobil ve ulaşım haberleri" }
                };

                await context.Categories.AddRangeAsync(categories);
                await context.SaveChangesAsync();
            }

            // ─── 5. Articles Seeding ──────────────────────────────────────────
            if (!await context.Articles.AnyAsync())
            {
                var techCategory = await context.Categories.FirstOrDefaultAsync(c => c.Slug == "teknoloji");
                var sportsCategory = await context.Categories.FirstOrDefaultAsync(c => c.Slug == "spor");
                var economyCategory = await context.Categories.FirstOrDefaultAsync(c => c.Slug == "ekonomi");
                var cultureCategory = await context.Categories.FirstOrDefaultAsync(c => c.Slug == "kultur-sanat");
                var gundemCategory = await context.Categories.FirstOrDefaultAsync(c => c.Slug == "gundem");
                var healthCategory = await context.Categories.FirstOrDefaultAsync(c => c.Slug == "saglik");

                var articles = new[]
                {
                    new Article
                    {
                        Title = "Yerli Yapay Zeka Modeli Yayınlandı: Türkçe Dil Performansında Rekor!",
                        Summary = "Türkiye merkezli teknoloji firması, tamamen Türkçe veri kümesiyle eğitilmiş yeni nesil yapay zeka modelini tanıttı.",
                        Content = "Geliştiriciler tarafından yapılan açıklamaya göre yeni yapay zeka modeli, Türkçe dil işleme testlerinde %94 başarı oranına ulaştı. Doğal dil anlama, özet çıkarma ve kod üretme yetenekleriyle öne çıkan model, açık kaynaklı olarak geliştiricilerin kullanımına sunuldu. Uzmanlar, bu gelişmenin Türk teknoloji ekosistemi için önemli bir dönüm noktası olduğunu belirterek, yerli yapay zeka çalışmalarının hız kazanacağını öngörüyor.",
                        CoverImageUrl = "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800",
                        CategoryId = techCategory?.Id ?? 1,
                        AuthorName = "Ahmet Yılmaz",
                        ViewCount = 1420,
                        LikeCount = 385,
                        IsBreaking = true,
                        IsFeatured = true,
                        PublishedAt = DateTime.UtcNow.AddHours(-1)
                    },
                    new Article
                    {
                        Title = "Milli Takım Son Dakika Golüyle Çeyrek Finale Yükseldi!",
                        Summary = "Nefes kesen mücadelede 90+4. dakikada gelen golle takımımız adını çeyrek finale yazdırdı.",
                        Content = "Avrupa Şampiyonası son 16 turu maçında milli takımımız rakibini 2-1 mağlup etti. Karşılaşmanın başından sonuna kadar üstün bir oyun sergileyen ekibimiz, duraklama dakikalarında bulduğu harika kafa golüyle stadyumu sevinçe boğdu. Teknik direktör maç sonrası yaptığı açıklamada oyuncularını tebrik etti.",
                        CoverImageUrl = "https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800",
                        CategoryId = sportsCategory?.Id ?? 2,
                        AuthorName = "Mehmet Demir",
                        ViewCount = 2890,
                        LikeCount = 912,
                        IsBreaking = true,
                        IsFeatured = true,
                        PublishedAt = DateTime.UtcNow.AddHours(-3)
                    },
                    new Article
                    {
                        Title = "Merkez Bankası Faiz Kararını Açıkladı: Piyasalar Hareketlendi",
                        Summary = "Para Politikası Kurulu merakla beklenen faiz kararını açıkladı.",
                        Content = "Merkez Bankası haftalık repo politika faiz oranını sabit tutma kararı aldı. Yapılan basın açıklamasında enflasyon beklentileri ve küresel ekonomik verilerin titizlikle incelendiği vurgulandı. Karar sonrası dolar ve euro kurlarında sınırlı bir yükseliş gözlenirken, Borsa İstanbul'da satış baskısı oluştu.",
                        CoverImageUrl = "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800",
                        CategoryId = economyCategory?.Id ?? 3,
                        AuthorName = "Zeynep Kaya",
                        ViewCount = 980,
                        LikeCount = 142,
                        IsBreaking = false,
                        IsFeatured = true,
                        PublishedAt = DateTime.UtcNow.AddHours(-5)
                    },
                    new Article
                    {
                        Title = "Uzay Teleskobu Yeni Bir Ötegezegen Keşfetti",
                        Summary = "Dünyadan 120 ışık yılı uzaklıkta yer alan gezegenin atmosferinde su buharı izlerine rastlandı.",
                        Content = "Gökbilimciler, gelişmiş uzay teleskobu verilerini inceleyerek Güneş sistemimiz dışında yeni bir gezegen tespit etti. Kendi yıldızının yaşanabilir bölgesinde bulunan gezegenin yüzey sıcaklığının sıvı halde su bulunmasına imkan tanıdığı açıklandı.",
                        CoverImageUrl = "https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800",
                        CategoryId = techCategory?.Id ?? 1,
                        AuthorName = "Dr. Can Öztürk",
                        ViewCount = 1840,
                        LikeCount = 512,
                        IsBreaking = false,
                        IsFeatured = true,
                        PublishedAt = DateTime.UtcNow.AddHours(-8)
                    },
                    new Article
                    {
                        Title = "Tarihi Restorasyon Tamamlandı: Sanatseverler İçin Kapılarını Yeniden Açtı",
                        Summary = "300 yıllık tarihi konak 2 yıl süren titiz restorasyon çalışmalarının ardından müze olarak hizmete girdi.",
                        Content = "Mimari mirası koruma projesi kapsamında baştan sona yenilenen konak, geleneksel el sanatları ve döneme ait nadide eserlere ev sahipliği yapıyor. Restorasyon sürecinde özel olarak yetiştirilen ustalar tarafından orijinal malzemelerle yapılan çalışmalar büyük beğeni topladı.",
                        CoverImageUrl = "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800",
                        CategoryId = cultureCategory?.Id ?? 4,
                        AuthorName = "Elif Şahin",
                        ViewCount = 650,
                        LikeCount = 88,
                        IsBreaking = false,
                        IsFeatured = false,
                        PublishedAt = DateTime.UtcNow.AddHours(-12)
                    },
                    new Article
                    {
                        Title = "Yeni Eğitim Reformu Yürürlüğe Girdi",
                        Summary = "Milli Eğitim Bakanlığı, müfredat değişikliklerini içeren yeni eğitim reformunu açıkladı.",
                        Content = "Yeni müfredat ile birlikte dijital okuryazarlık, yapay zeka temelleri ve çevre bilinci dersleri zorunlu hale getirildi. Öğrencilerin proje tabanlı öğrenme yöntemiyle daha aktif katılımı hedefleniyor. Öğretmenler için ise kapsamlı bir hizmet içi eğitim programı hazırlandı.",
                        CoverImageUrl = "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800",
                        CategoryId = gundemCategory?.Id ?? 1,
                        AuthorName = "Fatma Arslan",
                        ViewCount = 740,
                        LikeCount = 195,
                        IsBreaking = false,
                        IsFeatured = false,
                        PublishedAt = DateTime.UtcNow.AddDays(-1)
                    },
                    new Article
                    {
                        Title = "Elektrikli Araç Satışlarında Tarihi Rekor Kırıldı",
                        Summary = "Türkiye'de elektrikli araç satışları geçen yılın aynı dönemine göre %180 arttı.",
                        Content = "Otomotiv Distribütörleri Derneği verilerine göre, Türkiye'de elektrikli araç satışları tüm zamanların en yüksek seviyesine ulaştı. Yerli üretim elektrikli otomobilin seri üretime başlamasıyla birlikte pazar payı hızla artıyor. Şarj altyapısı yatırımları da paralel olarak hızlandırıldı.",
                        CoverImageUrl = "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=800",
                        CategoryId = economyCategory?.Id ?? 3,
                        AuthorName = "Burak Yıldız",
                        ViewCount = 1560,
                        LikeCount = 423,
                        IsBreaking = true,
                        IsFeatured = false,
                        PublishedAt = DateTime.UtcNow.AddHours(-6)
                    },
                    new Article
                    {
                        Title = "Sağlıklı Beslenme Trendleri: Uzmanlar Ne Diyor?",
                        Summary = "Beslenme uzmanları, 2026 yılının öne çıkan sağlıklı beslenme trendlerini açıkladı.",
                        Content = "Fermente gıdalar, bitkisel protein kaynakları ve adaptojenik bitkiler bu yılın en popüler beslenme trendleri arasında yer alıyor. Uzmanlar, işlenmiş gıda tüketiminin azaltılması ve mevsimsel beslenmenin önemine dikkat çekiyor. Prebiyotik ve probiyotik içeren gıdaların bağışıklık sistemi üzerindeki olumlu etkileri de araştırmalarla destekleniyor.",
                        CoverImageUrl = "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800",
                        CategoryId = healthCategory?.Id ?? 5,
                        AuthorName = "Dr. Ayşe Çelik",
                        ViewCount = 890,
                        LikeCount = 267,
                        IsBreaking = false,
                        IsFeatured = false,
                        PublishedAt = DateTime.UtcNow.AddDays(-2)
                    }
                };

                await context.Articles.AddRangeAsync(articles);
                await context.SaveChangesAsync();
            }

            // ─── 6. Comments Seeding ──────────────────────────────────────────
            if (!await context.Comments.AnyAsync())
            {
                var firstArticle = await context.Articles.FirstOrDefaultAsync();
                var secondArticle = await context.Articles.Skip(1).FirstOrDefaultAsync();

                if (firstArticle != null)
                {
                    var comments = new[]
                    {
                        new Comment
                        {
                            ArticleId = firstArticle.Id,
                            UserName = "Emre K.",
                            Content = "Harika bir gelişme! Yerli yapay zeka modelleri çok önemli.",
                            CreatedAt = DateTime.UtcNow.AddMinutes(-30)
                        },
                        new Comment
                        {
                            ArticleId = firstArticle.Id,
                            UserName = "Selin D.",
                            Content = "Açık kaynak olması ayrıca değerli. Teşekkürler paylaşım için.",
                            CreatedAt = DateTime.UtcNow.AddMinutes(-15)
                        },
                        new Comment
                        {
                            ArticleId = secondArticle?.Id ?? firstArticle.Id,
                            UserName = "Ali R.",
                            Content = "Son dakika golü muhteşemdi! Tebrikler milli takıma.",
                            CreatedAt = DateTime.UtcNow.AddHours(-1)
                        }
                    };

                    await context.Comments.AddRangeAsync(comments);
                    await context.SaveChangesAsync();
                }
            }
        }
    }
}
