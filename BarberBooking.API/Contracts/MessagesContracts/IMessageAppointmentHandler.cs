using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts.MessagesContracts
{
    public interface IMessageAppointmentHandler
    {
        Task Handle(CancellationToken cancellationToken);
    }
}