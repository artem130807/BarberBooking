using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Dto.DtoSalonAdmin;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonsAdmins.Queries.Handlers
{
    public class GetSalonsAdminsHandler : IRequestHandler<GetSalonsAdminsQuery, Result<List<DtoGetSalonAdmin>>>
    {
        private readonly ISalonsAdminRepository _salonsAdminRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        public GetSalonsAdminsHandler(ISalonsAdminRepository salonsAdminRepository, IMapper mapper, IUserContext userContext)
        {
            _salonsAdminRepository = salonsAdminRepository;
            _mapper = mapper;
            _userContext = userContext;
        }
        public async Task<Result<List<DtoGetSalonAdmin>>> Handle(GetSalonsAdminsQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var salonsAdmin = await _salonsAdminRepository.GetSalonsAdmin(userId);
            if(salonsAdmin.Count == 0)
                return Result.Success(new List<DtoGetSalonAdmin>());
            var result = _mapper.Map<List<DtoGetSalonAdmin>>(salonsAdmin);
            return Result.Success(result);
        }
    }
}