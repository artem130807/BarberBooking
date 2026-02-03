using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class SalonsRepository : ISalonsRepository
    {
        private readonly BarberBookingDbContext _context;
        public SalonsRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task<Salons> Add(Salons salon)
        {
            _context.Salons.Add(salon);
            return salon;
        }

        public async Task Delete(Guid Id)
        {
            await _context.Salons.Where(x => x.Id == Id).ExecuteDeleteAsync();
        }

        public async Task<List<Salons>> GetActiveSalons(string city)
        {
            return await _context.Salons.Where(x => x.Address.City == city && x.IsActive == true).ToListAsync();
        }

        public async Task<Salons> GetSalonById(Guid Id)
        {
            return await _context.Salons.FindAsync(Id);
        }

        public async Task<List<Salons>> GetSalons(string city)
        {
            return await _context.Salons.Where(x => x.Address.City == city).ToListAsync();
        }

        public async Task<List<Salons>> GetSalonsNameStartWith(string city ,string name)
        {
            return await _context.Salons.Where(x => x.Address.City == city && x.Name.StartsWith(name)).ToListAsync();
        }
    }
}