using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Dto.DtoSalonAdmin;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonsAdmins.Queries.Handlers
{
    public class GetSalonAdminHandler : IRequestHandler<GetSalonAdminQuery, Result<DtoGetSalonAdmin>>
    {
        private readonly ISalonsAdminRepository _salonsAdminRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        public GetSalonAdminHandler(ISalonsAdminRepository salonsAdminRepository, IMapper mapper, IUserContext userContext)
        {
            _salonsAdminRepository = salonsAdminRepository;
            _mapper = mapper;
            _userContext = userContext;
        } 
        public Task<Result<DtoGetSalonAdmin>> Handle(GetSalonAdminQuery query, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }
}