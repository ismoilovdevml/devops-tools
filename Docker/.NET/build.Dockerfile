FROM mcr.microsoft.com/dotnet/aspnet:6.0-focal AS base
WORKDIR /app
COPY ./project/. .
ENTRYPOINT ["dotnet", "Project.dll", "--urls=http://0.0.0.0:15032"]

# docker build -t document-convertor-docker .
# docker run -d -p 15032:15032 --name document-convertor-docker --restart always document-convertor-docker:latest
