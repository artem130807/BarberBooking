namespace IdentityService.Domain.Models;

public class Roles
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ICollection<Users> Users { get; set; } = new List<Users>();
    public ICollection<Permissions> Permissions { get; set; } = new List<Permissions>();
}
