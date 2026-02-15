using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts.EmailContracts
{
    public interface IEmailVerficationHandler
    {
        Task Handle(CancellationToken cancellationToken);
    }
}