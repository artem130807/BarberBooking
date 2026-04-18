using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonPhotosContracts;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Infrastructure.Persistence.Repositories
{
    public class SalonPhotosRepository:ISalonPhotosRepository
    {
        private readonly BarberBookingDbContext _context;
        public SalonPhotosRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task Add(SalonPhotos salonPhoto)
        {
            _context.SalonPhotos.Add(salonPhoto);
        }

        public async Task Delete(Guid Id)
        {
            await _context.SalonPhotos.Where(x => x.Id == Id).ExecuteDeleteAsync();
        }

        public async Task<SalonPhotos> GetById(Guid Id)
        {
            return await _context.SalonPhotos.FindAsync(Id);
        }

        public async Task<PagedResult<SalonPhotos>> GetPagedResult(Guid salonId, PageParams pageParams)
        {
            return await _context.SalonPhotos.AsNoTracking().Where(x => x.SalonId == salonId).ToPagedAsync(pageParams);
        }

        public async Task<string?> GetFirstPhotoUrlAsync(Guid salonId, CancellationToken cancellationToken = default)
        {
            return await _context.SalonPhotos.AsNoTracking()
                .Where(x => x.SalonId == salonId)
                .OrderBy(x => x.CreatedAt)
                .Select(x => x.PhotoUrl)
                .FirstOrDefaultAsync(cancellationToken);
        }

        public async Task<List<SalonPhotos>> GetPhotos(Guid salonId)
        {
            return await _context.SalonPhotos.Where(x => x.SalonId == salonId).ToListAsync();
        }
    }
}