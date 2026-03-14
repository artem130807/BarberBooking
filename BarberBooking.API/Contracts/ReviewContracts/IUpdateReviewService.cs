using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.ReviewContracts
{
    public interface IUpdateReviewService
    {
        Task UpdateAsync(Review review, DtoUpdateReview updateReview);
    }
}