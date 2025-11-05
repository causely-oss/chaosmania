FROM debian:trixie-slim

RUN apt-get update && apt-get install -y \
    ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETOS
ARG TARGETARCH

COPY ./out/chaosmania-${TARGETOS}-${TARGETARCH} /bin/chaosmania
COPY ./plans /plans
COPY ./scenarios /scenarios

# Create a user group 'chaosmania'
RUN groupadd --system --gid 3000 chaosmania

# Create a user 'chaosmania' under 'chaosmania'
RUN useradd --system --home-dir /home/chaosmania --uid 2000 --gid chaosmania --create-home chaosmania

# Chown all the files to the causely user.
RUN chown -R chaosmania:chaosmania /bin/chaosmania

# Switch to 'chaosmania'
USER 2000

ENTRYPOINT [ "/bin/chaosmania" ]