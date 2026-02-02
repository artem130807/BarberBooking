using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts
{
    public interface IUpdateMasterTimeSlotService
    {
        Task UpdateAsync(MasterTimeSlot timeSlot, DtoUpdateMasterTimeSlot dto);
    }
}