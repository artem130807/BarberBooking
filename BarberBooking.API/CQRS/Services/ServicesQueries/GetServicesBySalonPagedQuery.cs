using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Services.ServicesQueries
{
    public record GetServicesBySalonPagedQuery(Guid salonId, PageParams pageParams) : IRequest<Result<PagedResult<DtoServicesAdminListItem>>>;
}
