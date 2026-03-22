using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salon.Queries
{
    public record GetSalonAdminStatsQuery(Guid salonId) : IRequest<Result<DtoSalonAdminStats>>;
}
