FROM mcr.microsoft.com/dotnet/aspnet:6.0-focal AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS build
WORKDIR /src
COPY src/ .
RUN dotnet restore "DevBlog.Api/DevBlog.Api.csproj"
WORKDIR "/src/DevBlog.Api"
RUN dotnet build "DevBlog.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DevBlog.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DevBlog.Api.dll", "--urls=http://0.0.0.0:4001"]