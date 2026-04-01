using System;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Contracts
{
    public interface IAppointmentCreationValidator
    {
        Task<Result<ValidatedAppointmentCreationData>> ValidateAsync(
            DtoCreateAppointment dto,
            Guid userId,
            CancellationToken cancellationToken = default);
    }
}
