FROM dart:stable

WORKDIR /bot

# Install dependencies
COPY pubspec.* /bot/
RUN dart pub get

# Copy code
COPY . /bot/
RUN dart pub get --offline

# Compile bot into executable
RUN dart run nyxx_commands:compile --compile -o meetme.g.dart --no-compile bin/meetme.dart
RUN dart compile exe -o meetme meetme.g.dart

CMD [ "./meetme" ]
