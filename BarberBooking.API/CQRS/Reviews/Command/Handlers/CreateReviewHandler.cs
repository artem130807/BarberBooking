using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Domain.SalonDomain;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.VisualBasic;

namespace BarberBooking.API.CQRS.Reviews.Command.Handlers
{
    public class CreateReviewHandler : IRequestHandler<CreateReviewCommand, Result<DtoReviewInfo>>
    {
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IRatingService _ratingService;
        private readonly IUserContext _userContext;
        private readonly IReviewRepository _reviewRepository;
        private readonly IValidateReviewRepository _validateReviewRepository;
        private readonly IUserRepository _userRepository;
        private readonly IAppointmentsRepository _appointmentsRepository;
        public CreateReviewHandler(IMapper mapper, IUnitOfWork unitOfWork, IRatingService ratingService, IUserContext userContext, IReviewRepository reviewRepository, IValidateReviewRepository validateReviewRepository, IUserRepository userRepository, IAppointmentsRepository appointmentsRepository)
        {
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _ratingService = ratingService;
            _userContext = userContext;
            _reviewRepository = reviewRepository;
            _validateReviewRepository = validateReviewRepository;
            _userRepository = userRepository;
            _appointmentsRepository = appointmentsRepository;
        }

        public async Task<Result<DtoReviewInfo>> Handle(CreateReviewCommand command, CancellationToken cancellationToken)
        {
            if (!_userContext.IsAuthenticated || _userContext.UserId == Guid.Empty)
                return Result.Failure<DtoReviewInfo>("Необходима авторизация");

            var userId = _userContext.UserId;
            var user = await _userRepository.GetUserById(userId);
            if (user == null)
                return Result.Failure<DtoReviewInfo>("Пользователь не найден. Убедитесь, что вы зарегистрированы в приложении.");
            var valid = await _validateReviewRepository.Validate(command.dtoCreateReview);
            if(valid.IsFailure)
                return Result.Failure<DtoReviewInfo>(valid.Error);
                
            var review = await _reviewRepository.GetReviewByAppointmentId(command.dtoCreateReview.AppointmentId);
            if(review != null)
                return Result.Failure<DtoReviewInfo>("Вы уже оставляли отзыв на эту запись");
            if(review.Appointment.Status != Enums.AppointmentStatusEnum.Completed)
                return Result.Failure<DtoReviewInfo>("Вы не можете оставить отзыв на невыполненную запись");
                
            var CreateReview = Review.Create(command.dtoCreateReview.AppointmentId, userId,command.dtoCreateReview.SalonId, command.dtoCreateReview.MasterProfileId, 
            command.dtoCreateReview.SalonRating, command.dtoCreateReview.MasterRating, 
            command.dtoCreateReview.Comment);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.reviewRepository.Create(CreateReview);
                _unitOfWork.Commit();
            }catch(Exception e)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoReviewInfo>(e.Message);
            }
            await _ratingService.AddSalonRating(command.dtoCreateReview.SalonId, command.dtoCreateReview.SalonRating,cancellationToken);
            if (command.dtoCreateReview.MasterProfileId.HasValue)
                await _ratingService.AddMasterRating(command.dtoCreateReview.MasterProfileId.Value, command.dtoCreateReview.SalonRating, cancellationToken);
                
            var result = _mapper.Map<DtoReviewInfo>(CreateReview);
            return Result.Success(result);
        }
    }
}