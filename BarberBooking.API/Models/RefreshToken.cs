using System;
using System.Buffers.Text;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Threading.Tasks;
using BarberBooking.API.Enums;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class RefreshToken
    {
        public Guid Id {get; private set;}
        public string TokenHash {get; private set;}
        public Guid UserId {get; private set;}
        public Users User {get; private set;}
        public DateTime ExpiresAt {get; private set;}
        public bool IsRevoked {get; private set;}
        public string Devices {get; private set;}

        public static Result<RefreshToken> Create(Guid userId, byte[] array ,string devices)
        {
            var refreshToken = GenerateRefreshToken(array);
            var resfreshToken = new RefreshToken
            {
                Id = Guid.NewGuid(),
                TokenHash = refreshToken,
                UserId = userId,
                ExpiresAt = DateTime.Now.AddDays(180),
                IsRevoked = false,
                Devices = devices
            };
            return resfreshToken;
        }
        public void RevokedToken() => IsRevoked = true;
       
        private static string GenerateRefreshToken(byte[] array)
        {
            return Convert.ToBase64String(array);
        }
    }
}