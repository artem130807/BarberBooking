using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Infrastructure.Persistence.Repositories
{
    public class WeeklyTemplateRepository : IWeeklyTemplateRepository
    {
        private readonly BarberBookingDbContext _context;
        public WeeklyTemplateRepository(BarberBookingDbContext context)
        {
            _context = context;
        }
        public async Task Add(WeeklyTemplate weeklyTemplate)
        {
            _context.WeeklyTemplates.Add(weeklyTemplate);
        }

        public async Task Delete(Guid Id)
        {
            await _context.WeeklyTemplates.
            Where(x => x.Id == Id)
            .ExecuteDeleteAsync();
        }

        public async Task<WeeklyTemplate> GetWeeklyTemplate(Guid Id)
        {
            return await _context.WeeklyTemplates
            .Include(x => x.TemplateDays)
            .FirstOrDefaultAsync(x => x.Id == Id);
        }

        public async Task<List<WeeklyTemplate>> GetWeeklyTemplates(Guid masterId)
        {
            return await _context.WeeklyTemplates
            .Include(x => x.TemplateDays)
            .Where(x => x.MasterProfileId == masterId)
            .ToListAsync();
        }
    }
}