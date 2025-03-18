namespace dotnet_app;

using BCrypt.Net;
using Microsoft.AspNetCore.Rewrite;

public class App{
    public static void Main(string[] args){
        var builder = WebApplication.CreateBuilder(args);

        builder.WebHost.UseUrls("http://0.0.0.0:5217");
        //builder.Host.UseContentRoot(Path.Combine(builder.Environment.ContentRootPath, "wwwroot"));

        builder.Services.AddRazorPages();

        var app = builder.Build();

        app.UseStaticFiles();

        app.MapGet("/hello", (HttpContext httpContext) => {
            return new Message(message: "Hello, world!");
        });

        var rewrittenRoutes = new RewriteOptions();
        rewrittenRoutes.AddRewrite("/static", "/dotnet_static_page.html", true);
        rewrittenRoutes.AddRewrite("/dynamic", "/Dynamic/DotnetDynamicPage", true);

        app.UseRewriter(rewrittenRoutes);

        app.MapPost("/hash", (PasswordMessage msg) => {
            string hash = BCrypt.HashPassword(msg.password);

            return new PasswordMessage(password: hash);
        });

        app.Run();
    }
}

record Message(string message);

record PasswordMessage(string password);
