using System.Net;
using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts;

namespace IdentityService.Infrastructure.Validators;

public class DnsEmailValidator : IDnsEmailValidator
{
    public async Task<Result> ValidateEmailAsync(string Email)
    {
        if (string.IsNullOrWhiteSpace(Email))
            return Result.Failure("Укажите адрес электронной почты");

        if (!new System.ComponentModel.DataAnnotations.EmailAddressAttribute().IsValid(Email))
            return Result.Failure("Неверный формат адреса почты");

        if (!Email.Contains('@'))
            return Result.Failure("Неверный формат адреса почты");

        var domen = Email.Split('@')[1];
        try
        {
            var mxRecords = await Dns.GetHostAddressesAsync(domen);
            if (mxRecords.Length == 0)
                return Result.Failure("Домен почты не найден");
        }
        catch
        {
            return Result.Failure("Не удалось проверить домен почты");
        }

        var disposibleDomains = new HashSet<string>
        {
            "tempmail.com", "10minutemail.com", "guerrillamail.com",
            "mailinator.com", "yopmail.com", "throwawaymail.com"
        };

        if (disposibleDomains.Contains(domen.ToLower()))
            return Result.Failure("Временные почтовые ящики не поддерживаются");

        return Result.Success();
    }
}
