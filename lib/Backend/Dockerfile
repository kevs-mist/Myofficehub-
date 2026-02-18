# Dockerfile for OfficeHub Dart Backend
FROM dart:stable AS build

# Set the working directory
WORKDIR /app

# Copy pubspec and get dependencies
COPY pubspec.* ./
RUN dart pub get

# Copy the rest of the code
COPY . .

# Compile the server
RUN dart compile exe lib/main.dart -o server

# Use a minimal runtime image
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/server /app/bin/
COPY --from=build /app/service-account-key.json /app/service-account-key.json
# Note: .env is usually NOT included in docker images for security.
# Environment variables should be set in the hosting platform.

# Expose the port
EXPOSE 8081

# Start the server
CMD ["/app/bin/server"]
