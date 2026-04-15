# Create a stage for building the application.
FROM --platform=$BUILDPLATFORM dhi.io/dotnet:10-sdk AS build
ARG TARGETARCH

COPY . /source

WORKDIR /source/src

#   work in .NET 6.0.
RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages \
    dotnet publish -a ${TARGETARCH/amd64/x64} --use-current-runtime --self-contained false -o /app


# Create development Container
FROM dhi.io/dotnet:10-sdk AS development
COPY . /source
WORKDIR /source/src
CMD dotnet run --no-launch-profile

FROM dhi.io/aspnetcore:10 AS final
WORKDIR /app

# Copy everything needed to run the app from the "build" stage.
COPY --from=build /app .


ARG APP_UID=10001
RUN useradd \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${APP_UID}" \
    appuser
USER appuser

ENTRYPOINT ["dotnet", "myWebApp.dll"]
