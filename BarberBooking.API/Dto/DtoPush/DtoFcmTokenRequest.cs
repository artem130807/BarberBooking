namespace BarberBooking.API.Dto.DtoPush;

public class DtoFcmTokenRequest
{
    /// <summary>Токен из FirebaseMessaging.instance.getToken().</summary>
    public string Token { get; set; } = null!;
}
