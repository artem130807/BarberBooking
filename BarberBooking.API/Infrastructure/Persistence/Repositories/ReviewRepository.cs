using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.ExtensionsProject;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.ReviewFilters;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class ReviewRepository : IReviewRepository
    {
        private readonly BarberBookingDbContext _context;
        public ReviewRepository(BarberBookingDbContext context)
        {
            _context = context;
        }
        public async Task<Review> Create(Review review)
        {
            _context.Reviews.Add(review);
            return review;
        }

        public async Task Delete(Guid Id)
        {
            await _context.Reviews.Where(x => x.Id == Id).ExecuteDeleteAsync();
        }

        public async Task<Review> GetReviewByAppointmentId(Guid appointmentId)
        {
            return await _context.Reviews
            .Include(x => x.Appointment)
            .FirstOrDefaultAsync(x => x.AppointmentId == appointmentId);
        }

        public async Task<Review> GetReviewById(Guid Id)
        {
            return await _context.Reviews.FirstOrDefaultAsync(x => x.Id == Id);
        }

        public async Task<PagedResult<Review>> GetReviewsBySalonId(Guid salonId, PageParams pageParams)
        {
            return await _context.Reviews
            .Include(x => x.Client)
            .Include(x => x.MasterProfile)
            .Where(x => x.SalonId == salonId)
            .OrderByDescending(x => x.CreatedAt)
            .ToPagedAsync(pageParams);
        }
        public async Task<PagedResult<Review>> GetReviewsByMasterId(Guid masterId, PageParams pageParams)
        {
            return await _context.Reviews
            .Include(x => x.Client)
            .Where(x => x.MasterProfileId == masterId)
            .OrderByDescending(x => x.CreatedAt)
            .ToPagedAsync(pageParams);
        }

        public async Task<List<Review>> GetListReviewsBySalonId(Guid salonId)
        {
            return await _context.Reviews
            .Include(x => x.Client)
            .Include(x => x.MasterProfile)
            .Where(x => x.SalonId == salonId)
            .ToListAsync();
        }
        public async Task<List<Review>> GetListReviewsByMasterId(Guid masterId)
        {
            return await _context.Reviews
            .Include(x => x.Client)
            .Include(x => x.MasterProfile)
            .Include(x => x.Salon)
            .Where(x => x.MasterProfileId == masterId)
            .ToListAsync();
        }
        public async Task<PagedResult<Review>> GetReviewsBySalonIdSort(Guid salonId, PageParams pageParams, ReviewSort sort)
        {
            return await _context.Reviews
            .Include(x => x.Client)
            .Include(x => x.MasterProfile)
            .Where(x => x.SalonId == salonId)
            .FilterReviewSalon(sort)
            .ToPagedAsync(pageParams);
        }

        public async Task<PagedResult<Review>> GetReviewsByMasterIdSort(Guid masterId, PageParams pageParams, ReviewSort sort)
        {
            return await _context.Reviews
            .Include(x => x.Client)
            .Where(x => x.MasterProfileId == masterId)
            .FilterReviewMaster(sort)
            .ToPagedAsync(pageParams);
        }
        public async Task<PagedResult<Review>> GetReviewsByClientId(Guid clientId, PageParams pageParams)
        {
            return await _context.Reviews
            .Include(x => x.Salon)
            .Include(x => x.Appointment)
            .ThenInclude(x => x.Service)
            .Include(x => x.MasterProfile)
            .Include(x => x.Client)
            .Where(x => x.ClientId == clientId)
            .ToPagedAsync(pageParams);
        }

        public async Task<PagedResult<Review>> GetAllReviews(FilterReviews filterReviews, PageParams pageParams)
        {
            return await _context.Reviews
            .Include(x => x.Salon)
            .Include(x => x.Appointment)
            .ThenInclude(x => x.Service)
            .Include(x => x.MasterProfile)
            .Include(x => x.Client)
            .ToFilterReview(filterReviews)
            .ToPagedAsync(pageParams);
        }

        public async Task<PagedResult<Review>> GetLowRatingReviewsPaged(Guid? salonId, PageParams pageParams)
        {
            var query = _context.Reviews
                .AsNoTracking()
                .Include(x => x.Salon)
                .Include(x => x.Appointment)
                .ThenInclude(x => x.Service)
                .Include(x => x.MasterProfile)
                .Include(x => x.Client)
                .AsQueryable();

            if (salonId.HasValue)
                query = query.Where(x => x.SalonId == salonId.Value);

            query = query
                .OrderBy(x => x.SalonRating)
                .ThenBy(x => x.MasterRating ?? 6);

            return await query.ToPagedAsync(pageParams);
        }
    }
}