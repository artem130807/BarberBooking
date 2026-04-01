using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.Media.Commands;
using BarberBooking.API.Dto.DtoMedia;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;

namespace BarberBooking.API.CQRS.Media.Commands.Handlers;

public class UploadAdminImageHandler : IRequestHandler<UploadAdminImageCommand, Result<DtoUploadAdminImageResult>>
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

    public UploadAdminImageHandler(IWebHostEnvironment env)
    {
        _env = env;
    }

    public async Task<Result<DtoUploadAdminImageResult>> Handle(
        UploadAdminImageCommand command,
        CancellationToken cancellationToken)
    {
        var file = command.File;
        if (file == null || file.Length == 0)
            return Result.Failure<DtoUploadAdminImageResult>("Файл не выбран");
        if (file.Length > MaxBytes)
            return Result.Failure<DtoUploadAdminImageResult>("Файл больше 5 МБ");

        var ct = NormalizeContentType(file.ContentType, file.FileName ?? string.Empty);
        if (!Allowed.Contains(ct))
            return Result.Failure<DtoUploadAdminImageResult>("Нужен файл JPEG, PNG или WebP");

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
        await using (var stream = File.Create(fullPath))
            await file.CopyToAsync(stream, cancellationToken);

        var baseUrl = command.PublicBaseUrl.TrimEnd('/');
        var url = $"{baseUrl}/uploads/images/{name}";
        return Result.Success(new DtoUploadAdminImageResult { Url = url });
    }

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
