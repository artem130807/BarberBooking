using System;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using CSharpFunctionalExtensions;
using MediatR;
using Org.BouncyCastle.Asn1.Cms;

namespace BarberBooking.API.CQRS.MasterTimeSlotQueries.Handler
{
    public class GetByIdAsyncHandler : IRequestHandler<GetByIdAsyncQuery, Result<DtoMasterTimeSlotInfo>>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;
        public GetByIdAsyncHandler(
            IMasterTimeSlotRepository masterTimeSlotRepository,
            IMapper mapper,
            IUserContext userContext,
            IMasterProfileRepository masterProfileRepository)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }

        public async Task<Result<DtoMasterTimeSlotInfo>> Handle(GetByIdAsyncQuery query, CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<DtoMasterTimeSlotInfo>("Доступно только мастеру");

            var timeslot = await _masterTimeSlotRepository.GetByIdAsync(query.Id);
            if (timeslot == null)
                return Result.Failure<DtoMasterTimeSlotInfo>("Тайм слот не найден");
            if (timeslot.MasterId != master.Id)
                return Result.Failure<DtoMasterTimeSlotInfo>("Нет доступа");

            
            var dto = new DtoMasterTimeSlotInfo
            {
                Id = timeslot.Id, 
                MasterId = timeslot.MasterId,
                ScheduleDate = timeslot.ScheduleDate,
                StartTime = timeslot.StartTime,
                EndTime = timeslot.EndTime,
                Status = timeslot.Status,
                TimeSlotCount = timeslot.Appointments.Count()
            };
            return Result.Success(dto);
        }
    }
}
