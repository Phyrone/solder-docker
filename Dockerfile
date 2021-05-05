FROM ubuntu:20.04 as build
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y
RUN apt install -y git php7.4 php7.4-bcmath php7.4-cli php7.4-curl php7.4-fpm php7.4-json php7.4-mbstring php7.4-mysql php-redis php7.4-xml php7.4-zip
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer
RUN composer self-update
WORKDIR /build/
RUN git clone https://github.com/TechnicPack/TechnicSolder.git .
RUN composer install --no-dev --no-interaction
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

ENV APP_NAME="Docker Solder"
ENV APP_ENV=production
ENV APP_KEY=9FIFvciix66cd4v3q6qbCN31AiMcpip8YT
ENV DB_CONNECTION=mysql

RUN apt update -y
RUN apt install -y git php7.4 php7.4-bcmath php7.4-cli php7.4-curl php7.4-fpm php7.4-json php7.4-mbstring php7.4-mysql php-redis php7.4-xml php7.4-zip
RUN apt install nginx gettext-base -y 
#RUN apt install python3.8-minimal
RUN apt clean -y
COPY start.sh /usr/lib/start.sh
RUN chmod +x /usr/lib/start.sh
COPY nginx-template.conf /etc/nginx/site-template.conf

WORKDIR /app/
COPY --from=build /build/ /usr/lib/solder_template/
#USER 1000
CMD /usr/lib/start.sh