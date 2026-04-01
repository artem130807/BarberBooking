using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Infrastructure.Interceptors.Repositories
{
    public class OutboxMessageRepository : IOutboxMessageRepository
    {
        private readonly BarberBookingDbContext _context;
        public OutboxMessageRepository(BarberBookingDbContext context)
        {
            _context = context;
        }
        public async Task Add(OutboxMessage message)
        {
            _context.OutboxMessages.Add(message);
        }

        public async Task Remove(Guid Id)
        {
            await _context.OutboxMessages.Where(x => x.Id == Id).ExecuteDeleteAsync();
        }
    }
}