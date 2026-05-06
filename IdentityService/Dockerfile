FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://0.0.0.0:8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["IdentityService/IdentityService.Domain/IdentityService.Domain.csproj", "IdentityService/IdentityService.Domain/"]
COPY ["IdentityService/IdentityService.Application/IdentityService.Application.csproj", "IdentityService/IdentityService.Application/"]
COPY ["IdentityService/IdentityService.Infrastructure/IdentityService.Infrastructure.csproj", "IdentityService/IdentityService.Infrastructure/"]
COPY ["IdentityService/IdentityService.API/IdentityService.API.csproj", "IdentityService/IdentityService.API/"]
RUN dotnet restore "IdentityService/IdentityService.API/IdentityService.API.csproj"
COPY IdentityService/ IdentityService/
RUN dotnet publish "IdentityService/IdentityService.API/IdentityService.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "IdentityService.API.dll"]
