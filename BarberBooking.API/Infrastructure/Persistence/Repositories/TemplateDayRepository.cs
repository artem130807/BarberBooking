using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.TemplateDayContracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Infrastructure.Persistence.Repositories
{
    public class TemplateDayRepository : ITemplateDayRepository
    {
        private readonly BarberBookingDbContext _context;

        public TemplateDayRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task Add(TemplateDay templateDay)
        {
            await _context.TemplateDays.AddAsync(templateDay);
        }

        public async Task Delete(Guid id)
        {
            await _context.TemplateDays.Where(x => x.Id == id).ExecuteDeleteAsync();
        }

        public async Task<TemplateDay> GetById(Guid id)
        {
            return await _context.TemplateDays.FindAsync(id);
        }

        public async Task<List<TemplateDay>> GetByWeeklyTemplateId(Guid weeklyTemplateId)
        {
            return await _context.TemplateDays
                .Where(x => x.TemplateId == weeklyTemplateId)
                .OrderBy(x => x.DayOfWeek)
                .ToListAsync();
        }
    }
}
