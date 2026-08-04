using Business.Abstract;
using Entities.Concrete;
using Microsoft.AspNetCore.Mvc;

namespace WebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ArticlesController : ControllerBase
    {
        private readonly IArticleService _articleService;

        public ArticlesController(IArticleService articleService)
        {
            _articleService = articleService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _articleService.GetAllAsync();
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        [HttpGet("category/{categoryId}")]
        public async Task<IActionResult> GetByCategory(int categoryId)
        {
            var result = await _articleService.GetByCategoryAsync(categoryId);
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        [HttpGet("breaking")]
        public async Task<IActionResult> GetBreakingNews()
        {
            var result = await _articleService.GetBreakingNewsAsync();
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        [HttpGet("featured")]
        public async Task<IActionResult> GetFeaturedNews()
        {
            var result = await _articleService.GetFeaturedNewsAsync();
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        [HttpGet("search")]
        public async Task<IActionResult> Search([FromQuery] string q)
        {
            var result = await _articleService.SearchAsync(q);
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _articleService.GetByIdAsync(id);
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        [HttpPost]
        public async Task<IActionResult> Add([FromBody] Article article)
        {
            var result = await _articleService.AddAsync(article);
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] Article article)
        {
            var result = await _articleService.UpdateAsync(article);
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _articleService.DeleteAsync(id);
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        [HttpPost("{id}/view")]
        public async Task<IActionResult> IncrementView(int id)
        {
            var result = await _articleService.IncrementViewCountAsync(id);
            return Ok(result);
        }

        [HttpPost("{id}/like")]
        public async Task<IActionResult> IncrementLike(int id)
        {
            var result = await _articleService.IncrementLikeCountAsync(id);
            return Ok(result);
        }
    }
}
