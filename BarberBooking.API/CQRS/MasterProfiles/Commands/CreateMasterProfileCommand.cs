using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterProfile;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Commands
{
    public record CreateMasterProfileCommand(DtoCreateMasterProfile dtoCreateMasterProfile):IRequest<Result<DtoCreateProfileInfo>>;
}