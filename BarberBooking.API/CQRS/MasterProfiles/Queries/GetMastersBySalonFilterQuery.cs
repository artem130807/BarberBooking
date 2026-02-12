using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Filters.MasterProfile;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfiles.Queries
{
    public record GetMastersBySalonFilterQuery(Guid salonId, MasterProfileFilter filter):IRequest<Result<List<DtoMasterProfileShortInfo>>>;
}