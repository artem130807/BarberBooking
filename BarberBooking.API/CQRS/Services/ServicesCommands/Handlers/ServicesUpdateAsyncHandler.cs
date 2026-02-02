using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoServices;
using MediatR;

namespace BarberBooking.API.CQRS.ServicesCommands.Handlers
{
    public class ServicesUpdateAsyncHandler : IRequestHandler<ServicesUpdateAsyncCommand, DtoServicesInfo>
    {
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IServicesRepository _servicesRepository;
        private readonly IUpdateServicesService _updateServices;
        public ServicesUpdateAsyncHandler(IMapper mapper,IUnitOfWork unitOfWork, IServicesRepository servicesRepository, IUpdateServicesService updateServices)
        {
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _servicesRepository = servicesRepository;
            _updateServices = updateServices;
        }
        public async Task<DtoServicesInfo> Handle(ServicesUpdateAsyncCommand command, CancellationToken cancellationToken)
        {
            var service = await _servicesRepository.GetByIdAsync(command.Id);
            if(service == null)
                throw new InvalidOperationException("Такой услуги нету");
             try
            {
                _unitOfWork.BeginTransaction();
                await _updateServices.UpdateAsync(service, command.dtoUpdateServices);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                throw new InvalidOperationException(ex.Message);
            }
            return _mapper.Map<DtoServicesInfo>(service);
        }
    }
}