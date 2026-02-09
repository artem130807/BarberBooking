using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts
{
    public interface IMasterTimeSlotRepository
    {
        Task<MasterTimeSlot> CreateAsync(MasterTimeSlot timeSlot);
        Task DeleteAsync(Guid timeSlotId);
        Task<List<MasterTimeSlot>> CreateRangeAsync(List<MasterTimeSlot> timeSlots);
        Task<MasterTimeSlot?> GetByIdAsync(Guid id);
        Task<List<MasterTimeSlot>> GetByMasterAsync(Guid masterId, DateOnly date);
        Task<List<MasterTimeSlot>> GetAvailableSlotsAsync(Guid masterId, DateOnly date, TimeSpan serviceDuration);
        Task<MasterTimeSlot?> FindSlotAsync(Guid masterId, DateOnly date, TimeOnly startTime);
        Task<List<MasterTimeSlot>> GetTimeSlotsInSalon(Guid salonId, DateOnly date);
        Task<List<MasterTimeSlot>> GetAvailableSlotsInSalons(DateOnly date);
    }
}