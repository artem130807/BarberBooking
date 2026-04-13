using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonPhotosContracts;

namespace BarberBooking.API.Infrastructure.Persistence.Repositories
{
    public class SalonPhotosRepository:ISalonPhotosRepository
    {
        private readonly BarberBookingDbContext _context;
        public SalonPhotosRepository(BarberBookingDbContext context)
        {
            _context = context;
        }
    }
}