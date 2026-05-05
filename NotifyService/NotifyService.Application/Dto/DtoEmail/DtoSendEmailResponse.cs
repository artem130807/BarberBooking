namespace NotifyService.Application.Dto.DtoEmail;

public class DtoSendEmailResponse
{
    public string Message { get; set; } = string.Empty;
    public bool IsSuccess { get; set; }
}
