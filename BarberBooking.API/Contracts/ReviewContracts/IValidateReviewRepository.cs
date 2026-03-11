using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoReview;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Contracts.ReviewContracts
{
    public interface IValidateReviewRepository
    {
        Task<Result<string>> Validate(DtoCreateReview dtoCreateReview);
    }
}