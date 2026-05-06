FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://0.0.0.0:8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["NotifyService/NotifyService.Domain/NotifyService.Domain.csproj", "NotifyService/NotifyService.Domain/"]
COPY ["NotifyService/NotifyService.Application/NotifyService.Application.csproj", "NotifyService/NotifyService.Application/"]
COPY ["NotifyService/NotifyService.Infrastructure/NotifyService.Infrastructure.csproj", "NotifyService/NotifyService.Infrastructure/"]
COPY ["NotifyService/NotifyService.API/NotifyService.API.csproj", "NotifyService/NotifyService.API/"]
RUN dotnet restore "NotifyService/NotifyService.API/NotifyService.API.csproj"
COPY NotifyService/ NotifyService/
RUN dotnet publish "NotifyService/NotifyService.API/NotifyService.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "NotifyService.API.dll"]
