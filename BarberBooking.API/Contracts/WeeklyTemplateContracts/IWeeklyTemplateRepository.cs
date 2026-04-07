using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.WeeklyTemplateContracts
{
    public interface IWeeklyTemplateRepository
    {
        Task Add(WeeklyTemplate weeklyTemplate);
        Task<List<WeeklyTemplate>> GetWeeklyTemplates(Guid masterId);
        Task<WeeklyTemplate> GetWeeklyTemplate(Guid Id);
        Task Delete(Guid Id);
    }
}