using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Filters;
using BarberBooking.API.Migrations;

namespace BarberBooking.API.Repositories
{
    public class SalonStatisticRepository:ISalonStatisticRepository
    {
        private readonly BarberBookingDbContext _context;
        public SalonStatisticRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task Add(Models.SalonStatistic salonStatistic)
        {
            _context.SalonStatistics.Add(salonStatistic);
        }

        public async Task<PagedResult<Models.SalonStatistic>> GetSalonStatisctics(Guid salonId, PageParams pageParams)
        {
            return await _context.SalonStatistics.Where(x => x.SalonId == salonId).ToPagedAsync(pageParams);
        }

        public async Task<Models.SalonStatistic> GetSalonStatistic(Guid Id)
        {
            return await _context.SalonStatistics.FindAsync(Id);
        }
    }
}