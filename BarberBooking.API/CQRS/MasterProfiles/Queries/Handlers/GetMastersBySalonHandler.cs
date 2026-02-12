using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Queries
{
    public class GetMastersBySalonHandler : IRequestHandler<GetMastersBySalonQuery, Result<List<DtoMasterProfileShortInfo>>>
    {
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly  IMapper _mapper;
        public GetMastersBySalonHandler(IMasterProfileRepository masterProfileRepository, IMapper mapper)
        {
            _masterProfileRepository = masterProfileRepository;
            _mapper = mapper;
        }
        public async Task<Result<List<DtoMasterProfileShortInfo>>> Handle(GetMastersBySalonQuery query, CancellationToken cancellationToken)
        {
            var masterProfiles = await _masterProfileRepository.GetMastersBySalon(query.salonId);
            if(masterProfiles.Count == 0)
                return Result.Failure<List<DtoMasterProfileShortInfo>>("Мастера в этом салоне не найдены");
            var dto =  _mapper.Map<List<DtoMasterProfileShortInfo>>(masterProfiles);
            return Result.Success(dto);
        }
    }
}