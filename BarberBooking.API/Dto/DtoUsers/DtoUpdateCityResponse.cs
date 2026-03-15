namespace BarberBooking.API.Dto.DtoUsers
{
    /// <summary>
    /// Ответ при смене города: новый город и новый JWT с обновлённым claim userCity.
    /// Клиент должен сохранить токен, чтобы запросы салонов/мастеров использовали новый город.
    /// </summary>
    public class DtoUpdateCityResponse
    {
        public string City { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
    }
}
