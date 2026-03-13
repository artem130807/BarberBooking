using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries.Handlers
{
    public class GetReviewsByClientIdHandler:IRequestHandler<GetReviewsByClientIdQuery, Result<PagedResult<DtoReviewClientShortInfo>>>
    {
        private readonly IUserContext _userContext;
        private readonly IReviewRepository _reviewRepository;
        private readonly IMapper _mapper;
        public GetReviewsByClientIdHandler(IUserContext userContext, IReviewRepository reviewRepository, IMapper mapper)
        {
            _userContext = userContext;
            _reviewRepository = reviewRepository;
            _mapper = mapper;
        }
        public async Task<Result<PagedResult<DtoReviewClientShortInfo>>> Handle(GetReviewsByClientIdQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var reviews = await _reviewRepository.GetReviewsByClientId(userId, query.pageParams);
            if(reviews.Count == 0)
                return Result.Failure<PagedResult<DtoReviewClientShortInfo>>("Список ваших отзывов пуст");
            var result = _mapper.Map<PagedResult<DtoReviewClientShortInfo>>(reviews);
            return Result.Success(result);
        }
    }
}