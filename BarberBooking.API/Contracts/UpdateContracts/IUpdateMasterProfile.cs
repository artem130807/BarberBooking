using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts
{
    public interface IUpdateMasterProfile
    {
        Task UpdateAsync(MasterProfile masterProfile, DtoUpdateMasterProfile? dto);
    }
}