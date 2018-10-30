FROM php:7-apache

LABEL version="1.0.0" \
	description="Webserver for Contao CMS" \
	maintainer="Andreas Reinhold / surtic86 <surtic86@gmail.com>"

# install the PHP extensions we need
RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y \
		libicu-dev \
		libjpeg-dev \
		libpng-dev \
		libgmp-dev \
		libmcrypt-dev \
		libxml2-dev \
		mysql-common \
		libbz2-dev \
		zlib1g-dev \
		vim \
		libmagickwand-dev \
	; \
	apt-get clean; \
	rm -rf /var/lib/apt/lists/*; \
	ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/; \
        pecl install mcrypt-1.0.1 imagick; \
	export CFLAGS="-I/usr/src/php" ;\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
        docker-php-ext-enable mcrypt imagick; \
	docker-php-ext-install pdo pdo_mysql gd mysqli gmp bcmath zip xmlwriter xmlreader iconv bz2 mbstring soap intl

RUN a2enmod rewrite expires

# Document Root /var/www/html/web
# TimeZone
RUN set -ex; \
    perl -pi -e "s#/var/www/html#/var/www/html/web#" /etc/apache2/sites-available/000-default.conf ; \
    perl -pi -e "s#/var/www/html#/var/www/html/web#" /etc/apache2/sites-available/default-ssl.conf ; \
	echo "date.timezone = 'Europe/Zurich'\n" >> /usr/local/etc/php/php.ini

# Composer
RUN set -ex; \
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

VOLUME /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]
