# Dockerfile for development environment for Arduino projects.
# Includes IDE, platform tools, CLIs etc.

# Development environment needs a more elaborate setup with user
# permissions, since there are files being modified/created by
# both the container and the host. Therefore the development image
# is created with setting "node" as a user with the same USER_ID as
# the host user running the container.

# BASE_IMAGE is passed here. Rest of arguments are passed after
# FROM statement, because of https://github.com/moby/moby/issues/34129

ARG BASE_IMAGE=ubuntu:16.04

# Base image. Version is determined from argument

FROM ${BASE_IMAGE}

# Mandatory arguments passed to image.

ARG GROUP_ID
ARG USER_ID

# Optional arguments passed to image
# Version of Arduino IDE. Defaults to latest.
ARG IDE_VERSION="1.8.8"

# Enforce the passing of specific build-time parameters

RUN  : "${GROUP_ID:?USER_ID:?Build argument needs to be \
     set and non-empty.}"

# Replace 1000 with your user / group id
RUN mkdir -p /home/arduino && \
    mkdir -p /etc/sudoers.d && \
    groupadd -g ${GROUP_ID} arduino && \
    useradd -l -u ${USER_ID} -g arduino arduino && \
    install -d -m 0755 -o arduino -g arduino /home/arduino && \
    chown ${USER_ID}:${GROUP_ID} -R /home/arduino && \
    apt-get update && apt-get install -y \
        software-properties-common \
		wget \
		openjdk-9-jre \
		xvfb \
        xz-utils
    # && add-apt-repository ppa:ubuntuhandbook1/apps \
    # && apt-get update \
    # && apt-get install -y avrdude avrdude-doc \
	# && apt-get clean \
	# && rm -rf /var/lib/apt/lists/*

# Add arduino user to the dialout group to be able to write the serial USB device
RUN sed "s/^dialout.*/&arduino/" /etc/group -i \
    && sed "s/^root.*/&arduino/" /etc/group -i

RUN wget -q -O- https://downloads.arduino.cc/arduino-${IDE_VERSION}-linux64.tar.xz \
	| tar xJC /usr/local/share \
	&& ln -s /usr/local/share/arduino-${IDE_VERSION} /usr/local/share/arduino \
	&& ln -s /usr/local/share/arduino-${IDE_VERSION}/arduino /usr/local/bin/arduino

ENV DISPLAY :1.0

USER arduino