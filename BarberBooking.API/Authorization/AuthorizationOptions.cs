using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Authorization
{
    public class AuthorizationOptions
    {
        public RolePermissions[] RolePermissions { get; set; } = [];

    }
    public class RolePermissions
    {
        public string Role { get; set; } = string.Empty;
        public string[] Permissions { get; set; } = [];
    }
}