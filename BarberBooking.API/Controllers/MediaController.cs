using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.Media.Commands;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MediaController : ControllerBase
{
    private const long MaxBytes = 5 * 1024 * 1024;

    private readonly IMediator _mediator;

    public MediaController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [Authorize("AdminOrMaster")]
    [HttpPost("upload-image")]
    [RequestFormLimits(MultipartBodyLengthLimit = MaxBytes)]
    [RequestSizeLimit(MaxBytes)]
    public async Task<IActionResult> UploadImage(IFormFile? file, CancellationToken cancellationToken)
    {
        var publicBaseUrl = $"{Request.Scheme}://{Request.Host}";
        var command = new UploadAdminImageCommand(file, publicBaseUrl);
        var result = await _mediator.Send(command, cancellationToken);
        if (result.IsFailure)
            return BadRequest(new { error = result.Error });
        return Ok(result.Value);
    }
}
