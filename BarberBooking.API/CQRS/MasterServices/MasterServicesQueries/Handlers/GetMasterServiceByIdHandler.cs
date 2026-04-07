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
    public class GetMasterServiceByIdHandler : IRequestHandler<GetMasterServiceByIdQuery, Result<DtoMasterServiceInfo>>
    {
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public GetMasterServiceByIdHandler(
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

        public async Task<Result<DtoMasterServiceInfo>> Handle(
            GetMasterServiceByIdQuery query,
            CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<DtoMasterServiceInfo>("Доступно только мастеру");

            var link = await _unitOfWork.masterServicesRepository.GetByIdAsync(query.Id);
            if (link == null)
                return Result.Failure<DtoMasterServiceInfo>("Запись не найдена");
            if (link.MasterProfileId != master.Id)
                return Result.Failure<DtoMasterServiceInfo>("Нет доступа");

            var dto = _mapper.Map<DtoMasterServiceInfo>(link);
            return Result.Success(dto);
        }
    }
}
