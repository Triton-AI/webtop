ARG BASE_FROM
FROM $BASE_FROM as base
LABEL maintainer="Moises Lopez <mdlopezme@gmail.com>"

ARG APT_PACKAGES
COPY apt/${APT_PACKAGES} /tmp/${APT_PACKAGES}

RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends \
        $(cat /tmp/${APT_PACKAGES} | cut -d# -f1) && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/${APT_PACKAGES}

FROM base as builder

ARG CUSTOM_INSTALL_FILE
COPY custom/${CUSTOM_INSTALL_FILE} /tmp/${CUSTOM_INSTALL_FILE}
RUN DEBIAN_FRONTEND=noninteractive /bin/sh /tmp/${CUSTOM_INSTALL_FILE} && \
    rm -rf /tmp/${CUSTOM_INSTALL_FILE}

FROM builder as final

ARG BASH_SETTINGS_FILE
COPY bash/${BASH_SETTINGS_FILE} /config/.bashrc
RUN chown -R abc:abc /config

ARG TEST_INSTALL_FILE
COPY custom/${TEST_INSTALL_FILE} /tmp/${TEST_INSTALL_FILE}
RUN DEBIAN_FRONTEND=noninteractive /bin/sh /tmp/${TEST_INSTALL_FILE} && \
    rm -rf /tmp/${TEST_INSTALL_FILE}

FROM final as test