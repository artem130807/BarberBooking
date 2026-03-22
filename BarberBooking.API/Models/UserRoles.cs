using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class UserRoles
    {
        public Guid UserId { get; set; }
        public int RoleId { get; set; }

        public static Result<UserRoles> Create(Guid userId, int roleId)
        {
            var userRole = new UserRoles
            {
                UserId = userId,
                RoleId = roleId
            };
            return Result.Success(userRole);
        }
    }
}