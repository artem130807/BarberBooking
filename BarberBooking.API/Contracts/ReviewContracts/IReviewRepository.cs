using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.ReviewContracts
{
    public interface IReviewRepository
    {
        Task<Review> Create(Review review);
        Task Delete(Guid Id);
        Task<Review> GetReviewById(Guid Id);
        Task<List<Review>> GetListReviewsBySalonId(Guid salonId);
        Task<PagedResult<Review>> GetReviewsBySalonId(Guid salonId, PageParams pageParams);
        Task<PagedResult<Review>> GetReviewsByMasterId(Guid masterId, PageParams pageParams);
        Task<Review> GetReviewByAppointmentId(Guid appointmentId);
    }
}