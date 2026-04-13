using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonsAdmins.Commands.Handlers
{
    public class CreateSalonAdminHandler : IRequestHandler<CreateSalonAdminCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<CreateSalonAdminHandler> _logger;
        public CreateSalonAdminHandler( IUnitOfWork unitOfWork , ILogger<CreateSalonAdminHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _logger = logger;
        }
        public Task<Result<string>> Handle(CreateSalonAdminCommand command, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }
}