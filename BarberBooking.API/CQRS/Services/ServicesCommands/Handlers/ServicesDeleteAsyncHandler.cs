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
    public class ServicesDeleteAsyncHandler : IRequestHandler<ServicesDeleteAsyncCommand, DtoServicesShortInfo>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly IServicesRepository _servicesRepository;
        public ServicesDeleteAsyncHandler(IUnitOfWork unitOfWork, IMapper mapper, IServicesRepository servicesRepository)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _servicesRepository = servicesRepository;
        }

        public async Task<DtoServicesShortInfo> Handle(ServicesDeleteAsyncCommand command, CancellationToken cancellationToken)
        {
            var service = await _servicesRepository.GetByIdAsync(command.Id);
            if(service == null)
                throw new InvalidOperationException("Такой услуги не существует");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.servicesRepository.DeleteAsync(command.Id);
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