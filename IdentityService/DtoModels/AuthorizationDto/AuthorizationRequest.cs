using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.DtoModels
{
    public class AuthorizationRequest
    {
        public Guid UserId {get; set;}
        public string Action {get ;set;} = string.Empty;
        public string Resource {get; set;}
        public AuthorizationRequest(){}
    }
}