[![CI](https://github.com/gdamjan/tt-rss-service/actions/workflows/ci.yml/badge.svg)](https://github.com/gdamjan/tt-rss-service/actions/workflows/ci.yml)
[![Release](https://github.com/gdamjan/tt-rss-service/actions/workflows/release.yml/badge.svg)](https://github.com/gdamjan/tt-rss-service/actions/workflows/release.yml)

# `Tiny Tiny RSS` as a systemd portable service

This portable service image comes with:
* [Tiny Tiny RSS](https://tt-rss.org/)
* uwsgi as an application server, with php support
* php
* all the required php extensions

You need to provide:
* a database
* nginx and a virtual host
* lets encrypt certificate for https
* basic config file (see below)

All packed in an immutable [portable service](https://systemd.io/PORTABLE_SERVICES/) image. The image is built with
Nixos.

The service is configured in the `/etc/default/tt-rss.conf` file.

All state will be kept in the database and `/var/lib/private/tt-rss`.

## Quick Start

Get the latest image from [Github releases](https://github.com/gdamjan/tt-rss-service/releases/), into
`/var/lib/portables` and then run:

```sh
portablectl inspect tt-rss…
portablectl attach --enable --now tt-rss…
```

## Service configuration

The service is configured by the `/etc/default/tt-rss.conf` file. It's a simple [KEY=VALUE
file](https://www.freedesktop.org/software/systemd/man/systemd.exec.html#EnvironmentFile=),
with all keys beginning with `TTRSS_`.

Example:
```
TTRSS_SELF_URL_PATH=https://rss.example.com/
TTRSS_SESSION_COOKIE_LIFETIME=2592000
TTRSS_DB_TYPE=mysql
TTRSS_DB_HOST=db.example.com
TTRSS_DB_PORT=3306
TTRSS_DB_NAME=ttrss
TTRSS_DB_USER=ttrss
TTRSS_DB_PASS=example password
```

See https://git.tt-rss.org/fox/tt-rss/wiki/GlobalConfig for an explanation of the tt-rss configration system.

## External dependencies

The running service doesn't have an http server, database nor a certificate store. It only includes the tt-rss application
code, uwsgi with the php plugin, and the required php extensions. It exposes the `/run/tt-rss.sock` uwsgi
protocol socket, which can be used with nginx. This means that you have
to provide an nginx running on the "host", and a database running either on the same host or on a remote server.

I choose to use nginx on the "host" so that it can be shared with other services, and it makes
integration with LetsEncrypt/certbot easier. I personally also use a remote database server.


## Nginx configuration

The portable service will operate on the `/run/tt-rss.sock` uwsgi socket. We gonna let the host nginx handle
all the http, https and letsencrypt work. The config is simple, just proxy everything back to the uwsgi socket:
```
server {
    …
    location / {
        include uwsgi_params;
        uwsgi_pass unix:/run/tt-rss.sock;
    }
    …
}
```
> Note: even static files are served by the uwsgi server, but uwsgi has a good enough static files server, which doesn't
> block the application workers

## More info

See the [wiki](https://github.com/gdamjan/tt-rss-service/wiki/) for more info.
