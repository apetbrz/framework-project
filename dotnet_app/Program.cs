namespace dotnet_app;

using BCrypt.Net;
using Microsoft.AspNetCore.Rewrite;

public class App{
    public static void Main(string[] args){
        var builder = WebApplication.CreateBuilder(args);

        builder.WebHost.UseUrls("http://0.0.0.0:5217");
        //builder.Host.UseContentRoot(Path.Combine(builder.Environment.ContentRootPath, "wwwroot"));

        builder.Services.AddRazorPages().WithRazorPagesRoot("/Pages");

        var app = builder.Build();

        app.UseStaticFiles();

        app.MapGet("/", (HttpContext httpContext) => {
            return "asp.net webserver for spring 2025 senior project - arthur petroff";
        });

        app.MapGet("/hello", (HttpContext httpContext) => {
            return new Message(message: "Hello, world!");
        });

        app.UseRewriter(new RewriteOptions().AddRewrite("static", "dotnet_static_page.html", true));
        app.UseRewriter(new RewriteOptions().AddRewrite("dynamic", "Dynamic/dotnet_dynamic_page", true));

        app.MapPost("/hash", (PasswordMessage msg) => {
            Guid id = Guid.NewGuid();
            string hash = BCrypt.HashPassword(msg.password, 8);

            return new PasswordMessage(uuid: id, password: hash);
        });

        app.MapRazorPages();

        app.Run();
    }
}

record Message(string message);

record PasswordMessage(Guid uuid, string password);
