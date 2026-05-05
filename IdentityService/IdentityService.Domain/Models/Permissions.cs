namespace IdentityService.Domain.Models;

public class Permissions
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ICollection<Roles> Roles { get; set; } = new List<Roles>();
}
