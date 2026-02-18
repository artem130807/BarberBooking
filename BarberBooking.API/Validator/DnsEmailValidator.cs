using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.UserContratcts;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Validator
{
    public class DnsEmailValidator : IDnsEmailValidator
    {
        public async Task<Result> ValidateEmailAsync(string Email)
        {
            if (string.IsNullOrEmpty(Email) || string.IsNullOrWhiteSpace(Email))
            {
                return Result.Failure("Email не может быть пустым");
            }
            if (!new System.ComponentModel.DataAnnotations.EmailAddressAttribute().IsValid(Email))
            {
                return Result.Failure("Неверный формат email");
            }
            if (!Email.Contains("@"))
            {
                return Result.Failure("Неверный формат email");
            }
            var domen = Email.Split("@")[1];
            try
            {
                var mxRecords = await Dns.GetHostAddressesAsync(domen);
                if(mxRecords.Length == 0)
                {
                    return Result.Failure("Домент Email не существует");
                }
            }catch
            {
                return Result.Failure("");
            }
            var disposibleDomains = new HashSet<string>
            {
                 "tempmail.com", "10minutemail.com", "guerrillamail.com",
                 "mailinator.com", "yopmail.com", "throwawaymail.com"
            };
            if (disposibleDomains.Contains(domen.ToLower()))
            {
                return Result.Failure("Временные email не поддерживаются");
            }
           return Result.Success("Валидный емейл");
        }
    }
}