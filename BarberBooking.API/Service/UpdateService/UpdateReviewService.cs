using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Models;

namespace BarberBooking.API.Service.UpdateService
{
    public class UpdateReviewService : IUpdateReviewService
    {
        public async Task UpdateAsync(Review review, DtoUpdateReview? updateReview)
        {
            if (updateReview == null) return;

            if (updateReview.SalonRating.HasValue)
            {
                review.UpdateSalonRating(updateReview.SalonRating.Value);
            }

            if (updateReview.MasterRating.HasValue)
            {
                review.UpdateMasterRating(updateReview.MasterRating.Value);
            }

            if (!string.IsNullOrWhiteSpace(updateReview.Comment))
            {
                review.UpdateComment(updateReview.Comment);
            }

            await Task.CompletedTask; 
        }
    }
}