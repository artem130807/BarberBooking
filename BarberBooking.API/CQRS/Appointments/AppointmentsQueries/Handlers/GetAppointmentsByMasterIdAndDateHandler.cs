using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries.Handlers
{
    public class GetAppointmentsByMasterIdAndDateHandler : IRequestHandler<GetAppointmentsByMasterIdAndDateQuery, Result<DtoMasterAppointmentShortInfo>>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;
        public GetAppointmentsByMasterIdAndDateHandler(IAppointmentsRepository appointmentsRepository, IMapper mapper, IUserContext userContext, IMasterProfileRepository masterProfileRepository)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }

        public async Task<Result<DtoMasterAppointmentShortInfo>> Handle(GetAppointmentsByMasterIdAndDateQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var master = await _masterProfileRepository.GetMasterProfileByUserId(userId);
            var appointments = await _appointmentsRepository.GetByMasterIdAndDate(master.Id, query.appointmentDateTime, query.startTime);
            if(appointments == null)
                return Result.Failure<DtoMasterAppointmentShortInfo>("Список ваших записей пуст");
            var result  = _mapper.Map<DtoMasterAppointmentShortInfo>(appointments);
            return Result.Success(result);
        }
    }
}