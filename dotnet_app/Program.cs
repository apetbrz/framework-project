namespace dotnet_app;

using BCrypt.Net;

public class App{
    public static void Main(string[] args){
        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.
        // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen();
        builder.WebHost.UseUrls("http://0.0.0.0:5217");

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        app.MapGet("/", (HttpContext httpContext) => {
            return new Message(message: "Hello, world!");
        });

        app.MapPost("/hash", (PasswordMessage msg) => {
            string hash = BCrypt.HashPassword(msg.password);

            return new PasswordMessage(password: hash);
        });

        app.Run();
    }
}

record Message(string message);

record PasswordMessage(string password);
