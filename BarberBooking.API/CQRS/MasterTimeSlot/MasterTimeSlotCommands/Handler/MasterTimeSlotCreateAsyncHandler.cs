using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands.Handler
{
    public class MasterTimeSlotCreateAsyncHandler : IRequestHandler<MasterTimeSlotCreateAsyncCommand, Result<DtoMasterTimeSlotInfo>>
    {
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;
        public MasterTimeSlotCreateAsyncHandler(IMapper mapper, IUnitOfWork unitOfWork, IUserContext userContext, IMasterProfileRepository masterProfileRepository)
        {
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }
        public async Task<Result<DtoMasterTimeSlotInfo>> Handle(MasterTimeSlotCreateAsyncCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var masterProfile = await _masterProfileRepository.GetMasterProfileByUserId(userId);
            var timeSlot = MasterTimeSlot.Create(masterProfile.Id, command.dtoCreateMasterTimeSlot.ScheduleDate, 
            command.dtoCreateMasterTimeSlot.StartTime, command.dtoCreateMasterTimeSlot.EndTime);
            if(timeSlot.IsFailure)
                return Result.Failure<DtoMasterTimeSlotInfo>("Ошибка при создании слота");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterTimeSlotRepository.CreateAsync(timeSlot.Value);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                throw new InvalidOperationException(ex.Message);
            }
            return _mapper.Map<DtoMasterTimeSlotInfo>(timeSlot);
        }
    }
}