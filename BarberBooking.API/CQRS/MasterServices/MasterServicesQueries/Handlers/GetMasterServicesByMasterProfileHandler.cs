using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.CQRS.MasterServices.MasterServicesQueries;
using BarberBooking.API.Dto.DtoMasterServices;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterServices.MasterServicesQueries.Handlers
{
    public class GetMasterServicesByMasterProfileHandler
        : IRequestHandler<GetMasterServicesByMasterProfileQuery, Result<List<DtoMasterServiceInfo>>>
    {
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public GetMasterServicesByMasterProfileHandler(
            IMapper mapper,
            IUnitOfWork unitOfWork,
            IUserContext userContext,
            IMasterProfileRepository masterProfileRepository)
        {
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }

        public async Task<Result<List<DtoMasterServiceInfo>>> Handle(
            GetMasterServicesByMasterProfileQuery query,
            CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<List<DtoMasterServiceInfo>>("Доступно только мастеру");
            if (master.Id != query.MasterProfileId)
                return Result.Failure<List<DtoMasterServiceInfo>>("Нет доступа");

            var list = await _unitOfWork.masterServicesRepository.GetByMasterProfileIdAsync(query.MasterProfileId);
            var dto = _mapper.Map<List<DtoMasterServiceInfo>>(list);
            return Result.Success(dto);
        }
    }
}
