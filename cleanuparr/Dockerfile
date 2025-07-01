ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install bash for scripting
RUN apk add --no-cache bash

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
CMD []
