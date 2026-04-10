using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Contracts.AppointmentContracts
{
    public interface IAppointmentWithOutUserCreationValidator
    {
        Task<Result<ValidatedAppointmentCreationData>> ValidateAsync(
            DtoCreateAppointment dto,
            Guid userId,
            CancellationToken cancellationToken = default);
    }
}