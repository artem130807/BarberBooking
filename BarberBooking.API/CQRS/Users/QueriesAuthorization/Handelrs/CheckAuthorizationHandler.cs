using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.DtoModels.AuthorizationDto;
using MediatR;

namespace BarberBooking.CQRS.QueriesAuthorization.Handelrs
{
    public class CheckAuthorizationHandler : IRequestHandler<CheckAuthorizationQuery, AuthorizationAudit>
    {
        private readonly IUserRolesRepository _rolesRepository;
        private readonly IRolePermissionRepository _rolePermissionRepository;
        private readonly IPermissionsRepository _permissionRepository;
        public CheckAuthorizationHandler(IUserRolesRepository rolesRepository, IRolePermissionRepository rolePermissionRepository, IPermissionsRepository permissionRepository)
        {
            _rolesRepository = rolesRepository;
            _rolePermissionRepository = rolePermissionRepository;
            _permissionRepository = permissionRepository;
        }
        public async Task<AuthorizationAudit> Handle(CheckAuthorizationQuery query, CancellationToken cancellationToken)
        {
            if(query.authorizationRequest == null)
                return new AuthorizationAudit{Allowed = false, Reason = "Неверный запрос"};
            var roles = await _rolesRepository.GetRolesIdByUserId(query.authorizationRequest.UserId);
            if(roles.Count == 0)
                return new AuthorizationAudit{Allowed = false, Reason = "У пользователя нету ролей"};
        
            foreach(var role in roles)
            {
                var permission = await _rolePermissionRepository.GetPermissionIdByRoleId(role.RoleId);
              
                var permissionIds = permission.Select(p => p.PermissionId).ToList();
                var allPermissions = await _permissionRepository.GetPermissionsById(permissionIds);
                var hasPermission = allPermissions.Any(p => 
                string.Equals(p.Name, query.authorizationRequest.Action, StringComparison.OrdinalIgnoreCase));
                if (hasPermission)
                {
                    return new AuthorizationAudit{Allowed = true, Reason = $"Имеет право на {query.authorizationRequest.Action}"};
                }
                
            }
            return new AuthorizationAudit{Allowed = false, Reason = "У вас недостаточно прав"};
        }
    }
}