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
    public class GetAppointmentsByMasterIdAndDateHandler : IRequestHandler<GetAppointmentsByClientIdAndDateQuery, Result<List<DtoClientAppointmentShortInfo>>>
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
        public async Task<Result<List<DtoClientAppointmentShortInfo>>> Handle(GetAppointmentsByClientIdAndDateQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var master = await _masterProfileRepository.GetMasterProfileByUserId(userId);
            var appointments = await _appointmentsRepository.GetByMasterIdAndDate(master.Id, query.appointmentDateTime);
            if(appointments.Count == 0)
                return Result.Failure<List<DtoClientAppointmentShortInfo>>("Список ваших записей пуст");
            var result  = _mapper.Map<List<DtoClientAppointmentShortInfo>>(appointments);
            return Result.Success(result);
        }
    }
}