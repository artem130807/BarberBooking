using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.DtoModels
{
    public class DtoEventUserRegister
    {
        public Guid EventId {get; set;}
        public Guid UserId {get; set;}
        public Guid RoleId {get; set;}
        public string Name {get; set;}
        public string Email {get; set;}
    }
}