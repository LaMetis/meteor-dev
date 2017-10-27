FROM debian:latest
LABEL maintainer="nicolas.kahn@la-metis.fr"

# build arguments
ARG APP_PACKAGES
ARG APP_LOCALE=en_US
ARG APP_CHARSET=UTF-8
ARG APP_USER=app
ARG APP_USER_DIR=/home/${APP_USER}

# run environment
ENV APP_PORT=${APP_PORT:-3000}
ENV APP_ROOT=${APP_ROOT:-/app}

# exposed ports and volumes
EXPOSE $APP_PORT
VOLUME $APP_ROOT

# add packages for building NPM modules (required by Meteor)
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && apt-get -y dist-upgrade \
  && apt-get install -y curl python build-essential locales procps ${APP_PACKAGES} \
  && apt-get autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set the locale (required by Meteor)
RUN localedef -i ${APP_LOCALE} -c -f ${APP_CHARSET} -A /usr/share/locale/locale.alias ${APP_LOCALE}.${APP_CHARSET}
ENV LANG ${APP_LOCALE}.${APP_CHARSET}

# create a non-root user that can write to /usr/local (required by Meteor)
RUN useradd -mUd ${APP_USER_DIR} ${APP_USER}
RUN chown -Rh ${APP_USER} /usr/local
USER ${APP_USER}

# install Meteor
RUN curl https://install.meteor.com/?release=1.2.1 | sh

# run Meteor from the app directory
WORKDIR ${APP_ROOT}
ENTRYPOINT [ "/usr/local/bin/meteor" ]
