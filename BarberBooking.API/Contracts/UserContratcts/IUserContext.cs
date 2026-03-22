using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts
{
    public interface IUserContext
    {
        Guid UserId { get; }
        string UserCity {get;}
        bool IsAuthenticated { get; }
        IEnumerable<string> Roles {get;}
        bool IsInRole(string role);
    }
}