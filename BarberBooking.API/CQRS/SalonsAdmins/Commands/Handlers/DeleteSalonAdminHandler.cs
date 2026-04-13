using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonsAdmins.Commands.Handlers
{
    public class DeleteSalonAdminHandler : IRequestHandler<DeleteSalonAdminCommand, Result<string>>
    {
        private readonly ISalonsAdminRepository _salonsAdminRepository;
        private readonly IUnitOfWork _unitOfWork;
        public DeleteSalonAdminHandler(ISalonsAdminRepository salonsAdminRepository, IUnitOfWork unitOfWork)
        {
         _salonsAdminRepository = salonsAdminRepository;   
         _unitOfWork = unitOfWork;
        }
        public async Task<Result<string>> Handle(DeleteSalonAdminCommand command, CancellationToken cancellationToken)
        {
            return Result.Success("Успешно");
        }
    }
}