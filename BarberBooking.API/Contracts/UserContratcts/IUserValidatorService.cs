using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoUsers;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Contracts.UserContratcts
{
    public interface IUserValidatorService
    {
        Task<Result> ValidUser(DtoCreateUser dtoCreateUser);
    }
}