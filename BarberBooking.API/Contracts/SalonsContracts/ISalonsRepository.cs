using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.SalonsContracts
{
    public interface ISalonsRepository
    {
        Task<Salons> Add(Salons salon);
        Task Delete(Guid Id);
        Task<List<Salons>> GetSalons(string city);
        Task<List<Salons>> GetActiveSalons(string city);
        Task<Salons> GetSalonById(Guid Id);
        Task<List<Salons>> GetSalonsNameStartWith(SearchFilterParams searchParams);
        
    }
}