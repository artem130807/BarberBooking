using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Application.Contracts;
using IdentityService.Application.Contracts.Interfaces;
using IdentityService.Infrastructure.Persistence;
using IdentityService.Infrastructure.Persistence.Repositories;
using Microsoft.Extensions.Logging;

namespace IdentityService.Infrastructure.Services
{
    public class UnitOfWork : IUnitOfWork
    {
        IdentityServiceDbContext _context;
        private IUserRepository _userRepository;
        public UnitOfWork(IdentityServiceDbContext context)
        {
            _context = context;
        }         
        public IUserRepository userRepository
        {
            get{return _userRepository ?? new UsersRepository(_context);}
        }
        public void BeginTransaction()
        {
            _context.BeginTransaction();
        }

        public void Commit()
        {
            _context.SaveChanges();
            _context.CommitTransaction();
        }
        public void Dispose()
        {
            _context.Dispose();
        }
        public void RollBack()
        {
            _context.RollbackTransaction();
        }
    }
}