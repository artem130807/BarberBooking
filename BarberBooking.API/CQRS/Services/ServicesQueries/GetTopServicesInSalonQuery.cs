using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Services.ServicesQueries
{
    public record GetTopServicesInSalonQuery(Guid salonId, PageParams pageParams) : IRequest<Result<PagedResult<DtoServicesSearchResult>>>;
}
