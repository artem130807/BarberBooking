using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using BarberBooking.API.Dto.DtoWeeklyTemplate;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.WeeklyTemplate.Queries.Handlers
{
    public class GetWeeklyTemplatesHandler : IRequestHandler<GetWeeklyTemplatesQuery, Result<List<DtoWeeklyTemplateShortInfo>>>
    {

        private readonly IWeeklyTemplateRepository _weeklyTemplateRepository;
        private  readonly IUserContext _userContext;
        private  readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IMapper _mapper;
        public GetWeeklyTemplatesHandler(IWeeklyTemplateRepository weeklyTemplateRepository, IUserContext userContext, IMasterProfileRepository masterProfileRepository, IMapper mapper)
        {
            _weeklyTemplateRepository = weeklyTemplateRepository;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
            _mapper = mapper;
        }
        public async Task<Result<List<DtoWeeklyTemplateShortInfo>>> Handle(GetWeeklyTemplatesQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var master = await _masterProfileRepository.GetMasterProfileByUserId(userId);
            if(master == null)
                return Result.Failure<List<DtoWeeklyTemplateShortInfo>>("Профиль мастера не найден"); 
            var weeklyTemplates = await _weeklyTemplateRepository.GetWeeklyTemplates(master.Id);
            if(weeklyTemplates.Count == 0)
                return Result.Success(new List<DtoWeeklyTemplateShortInfo>());
            var result = weeklyTemplates.Select(x => new DtoWeeklyTemplateShortInfo
            {
                Id = x.Id,
                Name = x.Name,
                IsActive = x.IsActive,
                TemplateDayCount = x.TemplateDays.Count()
            }).ToList();
            return Result.Success(result);
        }
    }
}