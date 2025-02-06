namespace dotnet_app.Models;

public class PasswordHash{
    public required string Password { get; set; }
    public Guid Id{ get; set; }
}