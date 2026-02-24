using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.ReviewContracts;
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
            return await _context.Reviews.FirstOrDefaultAsync(x => x.AppointmentId == appointmentId);
        }

        public async Task<Review> GetReviewById(Guid Id)
        {
            return await _context.Reviews.FirstOrDefaultAsync(x => x.Id == Id);
        }

        public async Task<List<Review>> GetReviewsBySalonId(Guid salonId)
        {
            return await _context.Reviews.Where(x => x.SalonId == salonId).ToListAsync();
        }
    }
}