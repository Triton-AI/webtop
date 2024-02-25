ARG BASE_FROM
FROM $BASE_FROM as base
LABEL maintainer="Moises Lopez <mdlopezme@gmail.com>"

ARG APT_PACKAGES
COPY apt/${APT_PACKAGES} /tmp/${APT_PACKAGES}

FROM base as apt
# Install Apt packages
RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends \
        $(cat /tmp/${APT_PACKAGES} | cut -d# -f1) && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/${APT_PACKAGES}

FROM apt as custom
# Run the custom install file
ARG CUSTOM_INSTALL_FILE
COPY custom/${CUSTOM_INSTALL_FILE} /tmp/${CUSTOM_INSTALL_FILE}
RUN DEBIAN_FRONTEND=noninteractive /bin/sh /tmp/${CUSTOM_INSTALL_FILE} && \
    rm -rf /tmp/${CUSTOM_INSTALL_FILE}

FROM custom as pip
# Install pip packages
ARG PIP_PACKAGES
COPY pip/${PIP_PACKAGES} /tmp/${PIP_PACKAGES}
RUN pip3 install --no-cache-dir -r /tmp/${PIP_PACKAGES} && \
    rm -rf /tmp/${PIP_PACKAGES}

FROM pip as bash
# Append to the bashrc file
ARG BASH_SETTINGS_FILE
COPY bash/${BASH_SETTINGS_FILE} /tmp/.bashrc
RUN cat /tmp/.bashrc >> /root/.bashrc && \
    rm -rf /tmp/.bashrc

FROM bash as test
# Run the test install file
ARG TEST_INSTALL_FILE
COPY custom/${TEST_INSTALL_FILE} /tmp/${TEST_INSTALL_FILE}
RUN DEBIAN_FRONTEND=noninteractive /bin/sh /tmp/${TEST_INSTALL_FILE} && \
    rm -rf /tmp/${TEST_INSTALL_FILE}


