using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts
{
    public interface  IOutboxMessageRepository
    {
        Task Add(OutboxMessage message);
        Task Remove(Guid Id);
    }
}