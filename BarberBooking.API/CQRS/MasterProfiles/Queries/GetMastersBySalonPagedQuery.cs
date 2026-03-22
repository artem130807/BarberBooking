using System;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Queries
{
    public record GetMastersBySalonPagedQuery(Guid salonId, PageParams pageParams) : IRequest<Result<PagedResult<DtoMasterProfileInfo>>>;
}
