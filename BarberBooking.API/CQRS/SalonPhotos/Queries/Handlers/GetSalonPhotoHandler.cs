using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.SalonPhotosContracts;
using BarberBooking.API.Dto.DtoSalonPhotos;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonPhotos.Queries.Handlers
{
    public class GetSalonPhotoHandler : IRequestHandler<GetSalonPhotoQuery, Result<DtoSalonPhoto>>
    {
        private readonly ISalonPhotosRepository _salonPhotosRepository;
        private readonly IMapper _mapper;
        public GetSalonPhotoHandler(ISalonPhotosRepository salonPhotosRepository, IMapper mapper)
        {
            _salonPhotosRepository = salonPhotosRepository;
            _mapper = mapper;
        }
        public async Task<Result<DtoSalonPhoto>> Handle(GetSalonPhotoQuery query, CancellationToken cancellationToken)
        {
            var salonPhoto = await _salonPhotosRepository.GetById(query.Id);
            if(salonPhoto == null)
                return Result.Failure<DtoSalonPhoto>("Фотография не найдена");
            var result = _mapper.Map<DtoSalonPhoto>(salonPhoto);
            return Result.Success(result);
        }
    }
}