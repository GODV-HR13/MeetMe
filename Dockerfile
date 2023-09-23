FROM dart:stable

WORKDIR /bot

# Install dependencies
COPY pubspec.* /bot/
RUN dart pub get

# Copy code
COPY . /bot/
RUN dart pub get --offline

# Compile bot into executable
RUN dart run nyxx_commands:compile --compile -o discord_when2meet.g.dart --no-compile bin/discord_when2meet.dart
RUN dart compile exe -o discord_when2meet discord_when2meet.g.dart

CMD [ "./discord_when2meet" ]
