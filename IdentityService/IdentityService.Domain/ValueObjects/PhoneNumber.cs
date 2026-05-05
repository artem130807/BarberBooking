using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using CSharpFunctionalExtensions;
using ValueObject = IdentityService.Domain.Common.ValueObject;

namespace IdentityService.Domain.ValueObjects;

public sealed class PhoneNumber : ValueObject
{
    private const string Pattern = @"^(\+7|7|8)?[\s\-]?\(?\d{3}\)?[\s\-]?\d{3}[\s\-]?\d{2}[\s\-]?\d{2}$";

    public string Number { get; } = string.Empty;

    [JsonConstructor]
    private PhoneNumber(string number) => Number = number;

    private PhoneNumber() { }

    public static Result<PhoneNumber> Create(string number)
    {
        if (string.IsNullOrWhiteSpace(number))
            return Result.Failure<PhoneNumber>("Р СњР С•Р СР ВµРЎР‚ Р Р…Р Вµ Р СР С•Р В¶Р ВµРЎвЂљ Р В±РЎвЂ№РЎвЂљРЎРЉ Р С—РЎС“РЎРѓРЎвЂљРЎвЂ№Р С");
        if (!Regex.IsMatch(number, Pattern))
            return Result.Failure<PhoneNumber>("Р СњР С•Р СР ВµРЎР‚ Р Р…Р Вµ РЎРѓР С•Р С•РЎвЂљР Р†Р ВµРЎвЂљРЎРѓРЎвЂљР Р†РЎС“Р ВµРЎвЂљ РЎРѓРЎвЂљР В°Р Р…Р Т‘Р В°РЎР‚РЎвЂљРЎС“");
        return new PhoneNumber(number);
    }

    protected override IEnumerable<object> GetEqualityComponents()
    {
        yield return Number;
    }
}
