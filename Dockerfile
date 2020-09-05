FROM bunkerity/bunkerized-nginx

# Download PHPMyAdmin sources
ENV PMA_VERSION 5.0.2
RUN wget -O /tmp/phpmyadmin.zip https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/phpMyAdmin-${PMA_VERSION}-all-languages.zip && \
    unzip /tmp/phpmyadmin.zip -d /opt && \
    mv /opt/phpMyAdmin-${PMA_VERSION}-all-languages /opt/phpmyadmin-files

# Copy configs
COPY pma.conf /opt/pma.conf
COPY modsec.conf /opt/modsec.conf
COPY config.inc.php /opt/config.inc.php
COPY fail2ban /opt/pma-fail2ban

# Copy additional entrypoint
COPY entrypoint.sh /entrypoint.d/pma.sh
RUN chmod +x /entrypoint.d/pma.sh

# Custom config file directory
VOLUME /pma-conf

# Customize bunkerized-nginx environment variables
ENV ROOT_FOLDER /opt/phpmyadmin
ENV PHP_OPEN_BASEDIR /opt/phpmyadmin/:/tmp/:/pma-conf
ENV ADDITIONAL_MODULES php7-mysqli php7-session php7-ctype php7-json php7-mbstring php7-zip php7-gd php7-openssl php7-xml php7-xmlwriter php7-xmlreader php7-iconv php7-curl
