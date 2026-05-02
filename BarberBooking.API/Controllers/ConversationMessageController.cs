using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ConversationMessageController : ControllerBase
    {
        private readonly IMediator _mediator;
        public ConversationMessageController(IMediator mediator)
        {
            _mediator = mediator;
        }
    }
}