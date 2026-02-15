using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Service;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries.Handlers
{
    public class GetAppointmentsByMasterIdHandler : IRequestHandler<GetAppointmentsByMasterIdQuery, Result<List<DtoMasterAppointmentShortInfo>>>
    {
        private readonly IMapper _mapper;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;
        public GetAppointmentsByMasterIdHandler(IMapper mapper, IAppointmentsRepository appointmentsRepository, IUserContext userContext,IMasterProfileRepository masterProfileRepository)
        {
            _mapper = mapper;
            _appointmentsRepository = appointmentsRepository;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }
        public async Task<Result<List<DtoMasterAppointmentShortInfo>>> Handle(GetAppointmentsByMasterIdQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var master = await _masterProfileRepository.GetMasterProfileByUserId(userId);
            var appointments = await _appointmentsRepository.GetAppointmentsByMasterId(master.Id);
            if(appointments.Count == 0)
                return Result.Failure<List<DtoMasterAppointmentShortInfo>>("Список ваших записей пуст");
            var result  = _mapper.Map<List<DtoMasterAppointmentShortInfo>>(appointments);
            return Result.Success(result);
        }
    }
}