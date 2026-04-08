using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain.SalonDomain;
using BarberBooking.API.Dto;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Command.Handlers
{
    public class DeleteReviewHandler : IRequestHandler<DeleteReviewCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IReviewRepository _reviewRepository;
        private readonly IRollBackRatingService _rollBackRatingService;
        private readonly IUserContext _userContext;

        public DeleteReviewHandler(
            IUnitOfWork unitOfWork,
            IReviewRepository reviewRepository,
            IRollBackRatingService rollBackRatingService,
            IUserContext userContext)
        {
            _unitOfWork = unitOfWork;
            _reviewRepository = reviewRepository;
            _rollBackRatingService = rollBackRatingService;
            _userContext = userContext;
        }
        public async Task<Result<string>> Handle(DeleteReviewCommand command, CancellationToken cancellationToken)
        {
            var review = await _reviewRepository.GetReviewById(command.Id);
            if(review == null)
                return Result.Failure<string>("Отзыв не найден");
            if (review.ClientId != _userContext.UserId && !_userContext.IsInRole("Admin"))
                return Result.Failure<string>("Нет доступа");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.reviewRepository.Delete(command.Id);
                await _rollBackRatingService.RollBackSalonRating(review.SalonId, review.Id, cancellationToken);
                if (review.MasterProfileId.HasValue)
                {
                    await _rollBackRatingService.RollBackMasterRating(review.MasterProfileId.Value, review.Id, cancellationToken);
                }
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<string>(ex.Message);
            }
            return Result.Success("Успешно");
        }
    }
}