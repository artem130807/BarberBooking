using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.ConversationsContracts;
using BarberBooking.API.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.DependencyInjection;

namespace BarberBooking.API.Hubs
{
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public class ChatHub : Hub
    {
        private const string ConversationGroupPrefix = "conversation_";

        private readonly IServiceScopeFactory _serviceScopeFactory;

        public ChatHub(IServiceScopeFactory serviceScopeFactory)
        {
            _serviceScopeFactory = serviceScopeFactory;
        }

        public override async Task OnConnectedAsync()
        {
            var userId = Context.User?.FindFirstValue("userId")
                ?? Context.User?.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? Context.User?.FindFirstValue(JwtRegisteredClaimNames.Sub);

            if (string.IsNullOrEmpty(userId))
            {
                Context.Abort();
                return;
            }

            await base.OnConnectedAsync();
        }

        public override Task OnDisconnectedAsync(Exception? exception)
        {
            return base.OnDisconnectedAsync(exception);
        }

        public async Task JoinToChat(string chatName)
        {
            chatName = chatName?.Trim() ?? "";

            if (string.IsNullOrEmpty(chatName))
                throw new HubException("Chat name is required");

            if (!TryParseConversationGroup(chatName, out var conversationId))
                throw new HubException("Invalid chat name");

            await EnsureParticipantAndExecuteAsync(conversationId, async () =>
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, chatName);
            });
        }

        public async Task SendMessage(string chatName, string message)
        {
            chatName = chatName?.Trim() ?? "";

            if (string.IsNullOrEmpty(chatName))
                throw new HubException("Chat name is required");

            if (string.IsNullOrWhiteSpace(message))
                throw new HubException("Message cannot be empty");

            if (!TryParseConversationGroup(chatName, out var conversationId))
                throw new HubException("Invalid chat name");

            await EnsureParticipantAndExecuteAsync(conversationId, async () =>
            {
                var userName = Context.User?.Identity?.Name ?? "Anonymous";
                await Clients.Group(chatName).SendAsync("ReceiveMessages",
                    $"User  {userName} says - {message} from {chatName}");
            });
        }

        private static bool TryParseConversationGroup(string chatName, out Guid conversationId)
        {
            conversationId = default;
            if (string.IsNullOrEmpty(chatName) ||
                !chatName.StartsWith(ConversationGroupPrefix, StringComparison.Ordinal))
                return false;
            return Guid.TryParse(
                chatName.AsSpan(ConversationGroupPrefix.Length),
                out conversationId);
        }

        private Guid GetUserGuidOrThrow()
        {
            var userId = Context.User?.FindFirstValue("userId")
                ?? Context.User?.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? Context.User?.FindFirstValue(JwtRegisteredClaimNames.Sub);

            if (string.IsNullOrEmpty(userId) ||
                !Guid.TryParse(userId, out var g) ||
                g == Guid.Empty)
                throw new HubException("Unauthorized");

            return g;
        }

        private async Task EnsureParticipantAndExecuteAsync(
            Guid conversationId,
            Func<Task> action)
        {
            var userId = GetUserGuidOrThrow();

            using var scope = _serviceScopeFactory.CreateScope();
            var repo = scope.ServiceProvider.GetRequiredService<IConversationsRepository>();
            var conversation = await repo.GetConversation(conversationId);

            if (conversation == null)
                throw new HubException("Conversation not found");

            if (!conversation.HasParticipant(userId))
                throw new HubException("Forbidden");

            await action();
        }
    }
}
