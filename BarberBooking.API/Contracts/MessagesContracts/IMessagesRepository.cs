using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.MessagesContracts
{
    public interface IMessagesRepository
    {
        Task Add(Messages message);
        Task Delete(Guid Id);
        Task DeleteRange(List<Messages> messages);
        Task UpdateRange(List<Messages> messages);
        Task<Messages?> GetMessageByIdAsync(Guid id);
        Task<List<Messages>> GetMessages(Guid userId);
        Task<List<Messages>> GetUnreadMessages(Guid userId);
        Task<List<Messages>> GetMessagesByAppointmentId(Guid appointmentId);
        Task<Messages> GetMessagesMasterMessageCreationAppointment(Guid appointmentId);
        Task SaveChangesAsync();
    }
}