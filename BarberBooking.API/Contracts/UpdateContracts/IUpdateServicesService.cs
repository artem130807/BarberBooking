using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts
{
    public interface IUpdateServicesService
    {
        Task UpdateAsync(Services services, DtoUpdateServices dto);
    }
}