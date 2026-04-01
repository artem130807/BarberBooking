using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class MessagesRepository:IMessagesRepository
    {
        private readonly BarberBookingDbContext _context;
        public MessagesRepository(BarberBookingDbContext barberBookingDbContext)
        {
            _context = barberBookingDbContext;
        }

        public async Task Add(Messages message)
        {
            _context.Messages.Add(message);
        }

        public async Task DeleteRange(List<Messages> messages)
        {
            _context.Messages.RemoveRange(messages);
        }

        public async Task<List<Messages>> GetMessages(Guid userId)
        {
            return await _context.Messages.Where(x => x.UserId == userId).ToListAsync();
        }

        public async Task<List<Messages>> GetUnreadMessages(Guid userId)
        {
            return await _context.Messages.Where(x => x.UserId == userId && x.IsVisible == false).ToListAsync();
        }
        public async Task UpdateRange(List<Messages> messages)
        {
            _context.Messages.UpdateRange(messages);
        }
        public async Task<List<Messages>> GetMessagesByAppointmentId(Guid appointmentId)
        {
            return await _context.Messages.Where(x => x.AppointmentId == appointmentId).ToListAsync();
        }
        public async Task<Messages> GetMessagesMasterMessageCreationAppointment(Guid appointmentId)
        {
            return await _context.Messages.FirstOrDefaultAsync(x => x.AppointmentId == appointmentId 
            && x.Audience == Enums.MessageAudience.Master
            && x.TypeMessage == Enums.TypeMessage.CreationAppointment);
        }

    }
}