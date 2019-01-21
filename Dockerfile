FROM quay.io/inviqa_images/docker-spryker:7.2-fpm-alpine

COPY --from=mhart/alpine-node:8 /usr/bin/node /usr/bin/node
COPY --from=mhart/alpine-node:8 /usr/local/bin/yarn /usr/local/bin/yarn
COPY --from=mhart/alpine-node:8 /usr/lib/node_modules /usr/lib/node_modules
RUN ln -s /usr/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm

RUN apk --update add \
    # package dependencies \
    git \
    iproute2 \
    mysql-client \
    postgresql-client \
    nano \
    patch \
    redis \
    rsync \
    # clean \
    && rm -rf /var/cache/apk/*

# user: build
# -----------
RUN useradd --create-home --system build
ENV PATH "$PATH:/app/bin"

# tool: composer
# --------------
RUN curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/b107d959a5924af895807021fcef4ffec5a76aa9/web/installer \
    && php -r " \
    \$signature = '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061'; \
    \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
    unlink('/tmp/installer.php'); \
    echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
    exit(1); \
    }" \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer

# tool: composer > hirak/prestissimo
# ----------------------------------
# enables parallel downloading of composer depedencies and massively speeds up the
# time it takes to run composer install.
USER build
RUN composer global require hirak/prestissimo
USER root