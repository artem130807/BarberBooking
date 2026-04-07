using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts.MasterTimeSlotContracts
{
    public interface ITimeSlotQualifierBookedService
    {
        Task Handle(Guid timeSlotId, DateOnly date);
    }
}