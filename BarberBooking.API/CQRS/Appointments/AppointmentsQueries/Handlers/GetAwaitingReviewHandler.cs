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
    public class GetAwaitingReviewHandler : IRequestHandler<GetAwaitingReviewQuery, Result<PagedResult<DtoAppointmentAwaitingReview>>>
    {
        private readonly IUserContext _userContext;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        public GetAwaitingReviewHandler(IUserContext userContext, IAppointmentsRepository appointmentsRepository, IMapper mapper)
        {
            _userContext = userContext;
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
        }
        public async Task<Result<PagedResult<DtoAppointmentAwaitingReview>>> Handle(GetAwaitingReviewQuery query, CancellationToken cancellationToken)
        {
            if (!_userContext.IsAuthenticated || _userContext.UserId == Guid.Empty)
                return Result.Failure<PagedResult<DtoAppointmentAwaitingReview>>("Требуется авторизация");
            var userId = _userContext.UserId;
            var appointment = await _appointmentsRepository.GetCompletedAppointmentsByClientId(userId, query.pageParams);
            if(appointment.Count == 0)
                return Result.Failure<PagedResult<DtoAppointmentAwaitingReview>>("Список записей ожидающих отзыв пуст");
            var result = _mapper.Map<PagedResult<DtoAppointmentAwaitingReview>>(appointment);
            return Result.Success(result);
        }
    }
}