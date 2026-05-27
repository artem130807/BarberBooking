namespace NotifyService.Infrastructure.Push;

public class FirebasePushOptions
{
    public const string SectionName = "Firebase";

    public string? CredentialPath { get; set; }
    public string NotificationTitle { get; set; } = "BarberBooking";
}
