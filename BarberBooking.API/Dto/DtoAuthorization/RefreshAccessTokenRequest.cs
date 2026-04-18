namespace BarberBooking.API.Dto.DtoAuthorization
{
    public class RefreshAccessTokenRequest
    {
        public string RefreshToken { get; set; }
        public string Devices { get; set; }
    }
}
