FROM bunkerity/bunkerized-nginx

# Download PHPMyAdmin sources
ENV PMA_VERSION 5.0.2
RUN wget -O /tmp/phpmyadmin.zip https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/phpMyAdmin-${PMA_VERSION}-all-languages.zip && \
    unzip /tmp/phpmyadmin.zip -d /opt && \
    mv /opt/phpMyAdmin-${PMA_VERSION}-all-languages /opt/phpmyadmin-files && \
    rm -rf /opt/phpmyadmin-files/setup

# Copy PHPMyAdmin config
COPY config.inc.php /opt/config.inc.php

# Copy additional entrypoint
COPY entrypoint.sh /entrypoint.d/pma.sh
RUN chmod +x /entrypoint.d/pma.sh

# Customize bunkerized-nginx environment variables
ENV ROOT_FOLDER /opt/phpmyadmin
ENV PHP_OPEN_BASEDIR /opt/phpmyadmin/:/tmp/
ENV ADDITIONAL_MODULES php7-mysqli php7-session php7-ctype php7-json php7-mbstring php7-zip php7-gd php7-openssl php7-xml php7-xmlwriter php7-xmlreader php7-iconv
