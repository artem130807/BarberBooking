using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.CQRS.MasterServices.MasterServicesCommands;
using BarberBooking.API.Dto.DtoMasterServices;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterServices.MasterServicesCommands.Handlers
{
    public class DeleteMasterServiceHandler : IRequestHandler<DeleteMasterServiceCommand, Result<DtoMasterServiceInfo>>
    {
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public DeleteMasterServiceHandler(
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
            DeleteMasterServiceCommand command,
            CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<DtoMasterServiceInfo>("Доступно только мастеру");

            var link = await _unitOfWork.masterServicesRepository.GetByIdAsync(command.Id);
            if (link == null)
                return Result.Failure<DtoMasterServiceInfo>("Запись не найдена");
            if (link.MasterProfileId != master.Id)
                return Result.Failure<DtoMasterServiceInfo>("Нет доступа");

            var dto = _mapper.Map<DtoMasterServiceInfo>(link);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterServicesRepository.DeleteAsync(command.Id);
                _unitOfWork.Commit();
            }
            catch (System.Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoMasterServiceInfo>(ex.Message);
            }

            return Result.Success(dto);
        }
    }
}
