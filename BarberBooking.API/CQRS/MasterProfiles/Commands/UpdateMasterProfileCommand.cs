using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterProfile;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Commands
{
    public record UpdateMasterProfileCommand(Guid masterprofileId, DtoUpdateMasterProfile DtoUpdateMasterProfile):IRequest<Result<DtoMasterProfileInfo>>;
}