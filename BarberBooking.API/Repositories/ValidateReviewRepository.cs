using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Dto.DtoReview;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Repositories
{
    public class ValidateReviewRepository : IValidateReviewRepository
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IBadWordService _badWordService;
        public ValidateReviewRepository(IAppointmentsRepository appointmentsRepository, IBadWordService badWordService)
        {
            _appointmentsRepository = appointmentsRepository;
            _badWordService = badWordService;
        }
        public async Task<Result<string>> Validate(DtoCreateReview dtoCreateReview)
        {
            var appointment = await _appointmentsRepository.GetByIdAsync(dtoCreateReview.AppointmentId);
            if(appointment == null)
                return Result.Failure<string>("Запись не найдена");
            if(appointment.Status != Enums.AppointmentStatusEnum.Completed)
                return Result.Failure<string>("Запись еще не выполнена");
            if(_badWordService.IsTextValid(dtoCreateReview.Comment))
                return Result.Failure<string>("Напишите другой текст");
            return Result.Success("Успешно");
        }
    }
}