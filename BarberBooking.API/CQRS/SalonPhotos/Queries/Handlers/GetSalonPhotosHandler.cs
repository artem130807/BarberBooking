using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.SalonPhotosContracts;
using BarberBooking.API.Dto.DtoSalonPhotos;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonPhotos.Queries.Handlers
{
    public class GetSalonPhotosHandler : IRequestHandler<GetSalonPhotosQuery, Result<PagedResult<DtoSalonPhoto>>>
    {
        private readonly ISalonPhotosRepository _salonPhotosRepository;
        private readonly IMapper _mapper;
        public GetSalonPhotosHandler(ISalonPhotosRepository salonPhotosRepository, IMapper mapper)
        {
            _salonPhotosRepository = salonPhotosRepository;
            _mapper = mapper;
        }
        public async Task<Result<PagedResult<DtoSalonPhoto>>> Handle(GetSalonPhotosQuery query, CancellationToken cancellationToken)
        {
            var salonPhotos = await _salonPhotosRepository.GetPagedResult(query.salonId, query.pageParams);
            var dtoData = _mapper.Map<List<DtoSalonPhoto>>(salonPhotos.Data);
            return Result.Success(new PagedResult<DtoSalonPhoto>(dtoData, salonPhotos.Count));
        }
    }
}