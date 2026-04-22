using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace BarberBooking.API.Hubs
{
    public class ChatHub:Hub
    {
        public async Task JoinToChat(string chatName)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, chatName);
        }
        public async Task SendMessage(string chatName, string user, string message)
        {
            
        }
    }
}