using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.TemplateDayContracts
{
    public interface ITemplateDayRepository
    {
        Task Add(TemplateDay templateDay);
        Task<List<TemplateDay>> GetByWeeklyTemplateId(Guid weeklyTemplateId);
        Task<TemplateDay> GetById(Guid id);
        Task Delete(Guid id);
    }
}
