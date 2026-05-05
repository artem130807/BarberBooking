using System.Net;
using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts;

namespace IdentityService.Infrastructure.Validators;

public class DnsEmailValidator : IDnsEmailValidator
{
    public async Task<Result> ValidateEmailAsync(string Email)
    {
        if (string.IsNullOrWhiteSpace(Email))
            return Result.Failure("Email РЅРµ РјРѕР¶РµС‚ Р±С‹С‚СЊ РїСѓСЃС‚С‹Рј");

        if (!new System.ComponentModel.DataAnnotations.EmailAddressAttribute().IsValid(Email))
            return Result.Failure("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ email");

        if (!Email.Contains('@'))
            return Result.Failure("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ email");

        var domen = Email.Split('@')[1];
        try
        {
            var mxRecords = await Dns.GetHostAddressesAsync(domen);
            if (mxRecords.Length == 0)
                return Result.Failure("Р”РѕРјРµРЅ Email РЅРµ СЃСѓС‰РµСЃС‚РІСѓРµС‚");
        }
        catch
        {
            return Result.Failure("");
        }

        var disposibleDomains = new HashSet<string>
        {
            "tempmail.com", "10minutemail.com", "guerrillamail.com",
            "mailinator.com", "yopmail.com", "throwawaymail.com"
        };

        if (disposibleDomains.Contains(domen.ToLower()))
            return Result.Failure("Р’СЂРµРјРµРЅРЅС‹Рµ email РЅРµ РїРѕРґРґРµСЂР¶РёРІР°СЋС‚СЃСЏ");

        return Result.Success("Р’Р°Р»РёРґРЅС‹Р№ email");
    }
}
