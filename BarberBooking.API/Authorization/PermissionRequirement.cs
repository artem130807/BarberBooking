using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Enums;
using Microsoft.AspNetCore.Authorization;

namespace BarberBooking.API.Authorization
{
    public class PermissionRequirement(PermissionsEnum[] permissions):IAuthorizationRequirement
    {
        public PermissionsEnum[] Permissions = permissions;      
    }
}