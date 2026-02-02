using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Models;
using MediatR;

namespace BarberBooking.API.CQRS.ServicesCommands.Handlers
{
    public class ServicesCreateAsyncHandler : IRequestHandler<ServicesCreateAsyncCommand, DtoServicesShortInfo>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        public ServicesCreateAsyncHandler(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }
        public async Task<DtoServicesShortInfo> Handle(ServicesCreateAsyncCommand command, CancellationToken cancellationToken)
        {
            var dtoService = _mapper.Map<Services>(command.dtoCreateServices);
            var service = Services.Create(dtoService);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.servicesRepository.CreateAsync(service);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                throw new InvalidOperationException(ex.Message);
            }
            return _mapper.Map<DtoServicesShortInfo>(service);
        }
    }
}