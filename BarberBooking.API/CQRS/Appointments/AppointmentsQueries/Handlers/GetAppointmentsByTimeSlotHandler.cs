using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries.Handlers
{
    public class GetAppointmentsByTimeSlotHandler : IRequestHandler<GetAppointmentsByTimeSlotQuery, Result<PagedResult<DtoMasterAppointmentShortInfo>>>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        public GetAppointmentsByTimeSlotHandler(IAppointmentsRepository appointmentsRepository, IMapper mapper)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;  
        }
        public async Task<Result<PagedResult<DtoMasterAppointmentShortInfo>>> Handle(GetAppointmentsByTimeSlotQuery query, CancellationToken cancellationToken)
        {
            var appointments = await _appointmentsRepository.GetPagedAppointmentsByTimeSlotId(query.timeSlotId, query.pageParams, query.filter);
            var result = _mapper.Map<PagedResult<DtoMasterAppointmentShortInfo>>(appointments);
            return Result.Success(result);
        }
    }
}