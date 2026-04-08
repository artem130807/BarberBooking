using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries.Handlers
{
    public class GetAppointmentsByClientIdHandler : IRequestHandler<GetAppointmentsByClientIdQuery, Result<List<DtoClientAppointmentShortInfo>>>
    {
        private readonly IMapper _mapper;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IUserContext _userContext;
        public GetAppointmentsByClientIdHandler(IMapper mapper, IAppointmentsRepository appointmentsRepository, IUserContext userContext)
        {
            _mapper = mapper;
            _appointmentsRepository = appointmentsRepository;
            _userContext = userContext;
        }

        public async Task<Result<List<DtoClientAppointmentShortInfo>>> Handle(GetAppointmentsByClientIdQuery query, CancellationToken cancellationToken)
        {
            if (!_userContext.IsAuthenticated || _userContext.UserId == Guid.Empty)
                return Result.Failure<List<DtoClientAppointmentShortInfo>>("Требуется авторизация");
            Guid clientId = _userContext.UserId;
            var appointments = await _appointmentsRepository.GetAppointmentsByClientId(clientId);
            if(appointments.Count == 0)
                return Result.Failure<List<DtoClientAppointmentShortInfo>>("Список ваших записей пуст");
            var result  = _mapper.Map<List<DtoClientAppointmentShortInfo>>(appointments);
            return Result.Success(result);
        }
    }
}