using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
namespace BarberBooking.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MediaController : ControllerBase
{
    private const long MaxBytes = 5 * 1024 * 1024;
    private static readonly HashSet<string> Allowed = new(StringComparer.OrdinalIgnoreCase)
    {
        "image/jpeg",
        "image/jpg",
        "image/png",
        "image/webp",
    };

    private readonly IWebHostEnvironment _env;

    public MediaController(IWebHostEnvironment env)
    {
        _env = env;
    }

    [Authorize("Admin")]
    [HttpPost("upload-image")]
    [RequestFormLimits(MultipartBodyLengthLimit = MaxBytes)]
    [RequestSizeLimit(MaxBytes)]
    public async Task<IActionResult> UploadImage(IFormFile? file, CancellationToken cancellationToken)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { error = "Файл не выбран" });
        if (file.Length > MaxBytes)
            return BadRequest(new { error = "Файл больше 5 МБ" });
        var ct = NormalizeContentType(file.ContentType, file.FileName ?? string.Empty);
        if (!Allowed.Contains(ct))
            return BadRequest(new { error = "Нужен файл JPEG, PNG или WebP" });

        var ext = Path.GetExtension(file.FileName);
        if (string.IsNullOrEmpty(ext))
        {
            ext = ct.Contains("png", StringComparison.OrdinalIgnoreCase) ? ".png"
                : ct.Contains("webp", StringComparison.OrdinalIgnoreCase) ? ".webp"
                : ".jpg";
        }
        else
        {
            ext = ext.ToLowerInvariant();
            if (ext is not ".jpg" and not ".jpeg" and not ".png" and not ".webp")
                ext = ".jpg";
        }

        var webRoot = _env.WebRootPath;
        if (string.IsNullOrEmpty(webRoot))
            webRoot = Path.Combine(_env.ContentRootPath, "wwwroot");
        var uploads = Path.Combine(webRoot, "uploads", "images");
        Directory.CreateDirectory(uploads);
        var name = $"{Guid.NewGuid():N}{ext}";
        var fullPath = Path.Combine(uploads, name);
        await using (var stream = System.IO.File.Create(fullPath))
            await file.CopyToAsync(stream, cancellationToken);

        var baseUrl = $"{Request.Scheme}://{Request.Host}";
        var url = $"{baseUrl}/uploads/images/{name}";
        return Ok(new { url });
    }

    /// <summary>
    /// Клиенты часто шлют multipart без MIME-типа или с application/octet-stream.
    /// Дублируем тип по расширению имени файла.
    /// </summary>
    private static string NormalizeContentType(string? contentType, string fileName)
    {
        var ct = contentType ?? string.Empty;
        if (Allowed.Contains(ct))
            return ct;
        if (ct is "application/octet-stream" or "")
        {
            var ext = Path.GetExtension(fileName)?.ToLowerInvariant();
            if (ext is ".jpg" or ".jpeg")
                return "image/jpeg";
            if (ext == ".png")
                return "image/png";
            if (ext == ".webp")
                return "image/webp";
        }
        return ct;
    }
}
