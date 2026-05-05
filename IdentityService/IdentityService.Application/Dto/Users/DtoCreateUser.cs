using System.ComponentModel.DataAnnotations;

namespace IdentityService.Application.Dto.Users;

public class DtoCreateUser
{
    [Required]
    public string Name { get; set; } = string.Empty;

    [Required]
    public DtoPhone Phone { get; set; } = new();

    [Required]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string PasswordHash { get; set; } = string.Empty;

    [Required]
    public string City { get; set; } = string.Empty;

    [Required]
    public string Devices { get; set; } = string.Empty;
}
