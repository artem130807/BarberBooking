using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Command.Handlers
{
    public class UpdateReviewHandler : IRequestHandler<UpdateReviewCommand, Result<string>>
    {
        private readonly IUpdateReviewService _updateReviewService;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IReviewRepository _reviewRepository;
        private readonly IUpdateRatingService _updateRatingService;
        private readonly IUserContext _userContext;
        public UpdateReviewHandler(
            IUpdateReviewService updateReviewService,
            IUnitOfWork unitOfWork,
            IReviewRepository reviewRepository,
            IUpdateRatingService updateRatingService,
            IUserContext userContext)
        {
            _updateReviewService = updateReviewService;
            _unitOfWork = unitOfWork;
            _reviewRepository = reviewRepository;
            _updateRatingService = updateRatingService;
            _userContext = userContext;
        }
        public async Task<Result<string>> Handle(UpdateReviewCommand command, CancellationToken cancellationToken)
        {
            var review = await _reviewRepository.GetReviewById(command.Id);
            if(review == null)
                return Result.Failure<string>("Ваш отзыв не найден");
            if (review.ClientId != _userContext.UserId && !_userContext.IsInRole("Admin"))
                return Result.Failure<string>("Нет доступа");
            try
            {
                _unitOfWork.BeginTransaction();
                if (command.dtoUpdateReview.SalonRating.HasValue)
                {
                    await _updateRatingService.UpdateSalonRating(review.SalonId, review.Id, command.dtoUpdateReview.SalonRating , cancellationToken);
                }
                if (review.MasterProfileId.HasValue && command.dtoUpdateReview.MasterRating.HasValue)
                {
                    await _updateRatingService.UpdateMasterRating(review.MasterProfileId.Value, review.Id, command.dtoUpdateReview.MasterRating, cancellationToken);
                }
                await _updateReviewService.UpdateAsync(review, command.dtoUpdateReview);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<string>($"{ex.Message}");
            }
            return Result.Success("Успешно");
        }
    }
}