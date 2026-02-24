using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries.Handlers
{
    public class GetReviewsBySalonIdHandler : IRequestHandler<GetReviewsBySalonIdQuery, Result<List<DtoReviewShortInfo>>>
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IMapper _mapper;
        public GetReviewsBySalonIdHandler(IReviewRepository reviewRepository, IMapper mapper)
        {
            _reviewRepository = reviewRepository;
            _mapper = mapper;
        }
        public async Task<Result<List<DtoReviewShortInfo>>> Handle(GetReviewsBySalonIdQuery query, CancellationToken cancellationToken)
        {
            var reviews = await _reviewRepository.GetReviewsBySalonId(query.salonId);
            if(reviews.Count == 0)
                return Result.Failure<List<DtoReviewShortInfo>>("Список отзывов пуст");
            var result = _mapper.Map<List<DtoReviewShortInfo>>(reviews);
            return Result.Success(result);
        }
    }
}