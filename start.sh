#!/bin/bash

declare INSTALLED_FILE='./.installed'
declare INSTALLED_DB_FILE='./.installed_db'




function checkDatabase(){
    if [ -f "$INSTALLED_DB_FILE" ]; then
        startServer
    else 
        setupDatabase
    fi
}
function checkSetup(){
    if [ -f "$INSTALLED_FILE" ]; then
        checkDatabase
    else 
        setupServer
    fi
}
function prepareWorkdir(){
    if [ -z "$(ls -A)" ]; then
    cp /usr/lib/solder_template/* . -r
    #cp /usr/lib/solder_template/.env.example .
    touch ".env"
    fi
    checkSetup
}

function setupServer(){
    echo "Setup Server..."
    if [ ! -f ".env" ]; then 
        #echo ".env config not found please create first!"
        #exit 1
        touch ".env"
    fi
    php artisan key:generate --no-interaction --force -vvv
    touch "$INSTALLED_FILE"
    checkDatabase
}
function setupDatabase(){
    echo "Setup Database..."
    php artisan migrate --no-interaction --force
    touch "$INSTALLED_DB_FILE"
    startServer
}


function startServer(){
    if [ $(id -u) = 0 ]; then
        chown -R www-data ./*
    fi

    local PWD="$(realpath .)"
    echo "set nginx root dir to $PWD"
    envsubst '$PWD' < /etc/nginx/site-template.conf > /etc/nginx/sites-enabled/default
    echo "Starting PHP..."
    php-fpm7.4
    echo "Starting Server..."
    nginx -g 'daemon off;'
}



prepareWorkdir