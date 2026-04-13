using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class SalonsAdmin
    {
        public Guid Id {get; private set;}
        public Guid UserId {get; private set;}
        public Guid SalonId {get; private set;}
        public Users User {get; private set;}
        public Salons Salon {get; private set;}

        public static Result<SalonsAdmin> Create(Guid userId, Guid salonId)
        {
            var salonAdmin = new SalonsAdmin
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                SalonId = salonId
            };
            return salonAdmin;
        }
    }
}