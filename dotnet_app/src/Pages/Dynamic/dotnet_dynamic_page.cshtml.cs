using Microsoft.AspNetCore.Mvc.RazorPages;

namespace dotnet_app.Pages;

public class ExperimentalDynamicPageModel(ILogger<ExperimentalDynamicPageModel> logger) : PageModel
{
    private readonly ILogger<ExperimentalDynamicPageModel> _logger = logger;
    private readonly Random rand = new Random();

    public void OnGet()
    {
        ViewData["headerValue"] = Request.Headers["Experimental-Data"].ToString();
        ViewData["randomNumber"] = rand.NextDouble(); // For demo purposes only
    }
}