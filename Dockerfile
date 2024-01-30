# Official Dart image: https://hub.docker.com/_/dart
FROM dart:stable AS build

# Set the working directory for packages
WORKDIR /packages/jobstash_api
COPY ./packages/jobstash_api ./
RUN dart pub get
RUN dart pub run build_runner build --delete-conflicting-outputs

WORKDIR /packages/database
COPY ./packages/database ./
RUN dart pub get

# Set the working directory for app and copy its contents
WORKDIR /app
COPY ./ ./
RUN dart pub get
RUN dart pub run build_runner build --delete-conflicting-outputs

RUN dart compile exe bin/server.dart -o bin/server

# Build minimal serving image
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

# Start server
EXPOSE 8080
ENTRYPOINT ["/app/bin/server"]
