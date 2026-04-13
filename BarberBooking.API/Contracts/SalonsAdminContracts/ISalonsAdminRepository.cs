using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.SalonsAdminContracts
{
    public interface ISalonsAdminRepository
    {
        Task Add(SalonsAdmin salonsAdmin);
        Task Delete(Guid Id);
        Task<SalonsAdmin> GetById(Guid Id);
        Task<List<SalonsAdmin>> GetSalonsAdmin(Guid userId);
    }
}