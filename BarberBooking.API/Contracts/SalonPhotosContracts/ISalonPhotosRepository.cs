using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.SalonPhotosContracts
{
    public interface ISalonPhotosRepository
    {
        Task Add(SalonPhotos salonPhoto);
        Task Delete(Guid Id);
        Task<SalonPhotos> GetById(Guid Id);
        Task<List<SalonPhotos>> GetPhotos(Guid salonId);
        Task<PagedResult<SalonPhotos>> GetPagedResult(Guid salonId, PageParams pageParams);
        Task<string?> GetFirstPhotoUrlAsync(Guid salonId, CancellationToken cancellationToken = default);
    }
}