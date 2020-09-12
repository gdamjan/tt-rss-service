[![Build Status](https://github.com/gdamjan/tt-rss-service/workflows/Make%20a%20release/badge.svg)](https://github.com/gdamjan/tt-rss-service/actions)

# `TinyTiny RSS as a systemd portable service`

Build an immutable [Tiny Tiny RSS](https://tt-rss.org/) image for a systemd [portable service](https://systemd.io/PORTABLE_SERVICES/).
Made with uwsgi and nixos.

## Quick Start

Get the latest image from a [Github release](https://github.com/gdamjan/tt-rss-service/releases/), into
`/var/lib/portables` and then run:

```sh
portablectl attach --enable --now tt-rss
```

The service **has** to be configured in the `/etc/tt-rss/config.env` file before it's started, see bellow.
All state will be kept in `/var/lib/private/tt-rss`.

The running service is available via the `/run/tt-rss.sock` uwsgi
socket that can be used in nginx.

## Application configuration

The service is configured by the `/etc/tt-rss/config.env`, which is a simple `Key=Value` file that sets the process
environment. It is read by the [EnvironmentFile](https://www.freedesktop.org/software/systemd/man/systemd.exec.html#EnvironmentFile=)
directive in the service.

Example:
```
DB_TYPE=mysql
DB_HOST=localhost
DB_NAME=ttrss
DB_USER=tt-rss
DB_PASS=tt-rss
DB_PORT=3306
SELF_URL_PATH=http://localhost:8080/
```

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
