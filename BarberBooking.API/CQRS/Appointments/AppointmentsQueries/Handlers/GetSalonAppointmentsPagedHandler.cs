using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries.Handlers
{
    public class GetSalonAppointmentsPagedHandler : IRequestHandler<GetSalonAppointmentsPagedQuery, Result<PagedResult<DtoSalonAppointmentAdmin>>>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;

        public GetSalonAppointmentsPagedHandler(IAppointmentsRepository appointmentsRepository, IMapper mapper)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
        }

        public async Task<Result<PagedResult<DtoSalonAppointmentAdmin>>> Handle(GetSalonAppointmentsPagedQuery query, CancellationToken cancellationToken)
        {
            var appointments = await _appointmentsRepository.GetAllAppointments(query.salonId, query.from, query.to, query.filter, query.pageParams);
            if (appointments.Count == 0)
                return Result.Failure<PagedResult<DtoSalonAppointmentAdmin>>("Список записей пуст");
            var result = _mapper.Map<PagedResult<DtoSalonAppointmentAdmin>>(appointments);
            return Result.Success(result);
        }
    }
}
