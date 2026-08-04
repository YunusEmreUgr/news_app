using Business.Abstract;
using Microsoft.AspNetCore.Mvc;

namespace WebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BookmarksController : ControllerBase
    {
        private readonly IBookmarkService _bookmarkService;

        public BookmarksController(IBookmarkService bookmarkService)
        {
            _bookmarkService = bookmarkService;
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserBookmarks(int userId)
        {
            var result = await _bookmarkService.GetUserBookmarkedArticlesAsync(userId);
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        [HttpPost("toggle")]
        public async Task<IActionResult> ToggleBookmark([FromQuery] int userId, [FromQuery] int articleId)
        {
            var result = await _bookmarkService.ToggleBookmarkAsync(userId, articleId);
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        [HttpGet("check")]
        public async Task<IActionResult> IsBookmarked([FromQuery] int userId, [FromQuery] int articleId)
        {
            var result = await _bookmarkService.IsBookmarkedAsync(userId, articleId);
            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }
    }
}
