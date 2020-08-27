![Make a release](https://github.com/gdamjan/tt-rss-service/workflows/Make%20a%20release/badge.svg)

# `TinyTiny RSS as a systemd portable service`

Build a [Tiny Tiny RSS](https://tt-rss.org/) image for a systemd [portable service](https://systemd.io/PORTABLE_SERVICES/).

## Quick Start

Get the latest image from [Github release](https://github.com/gdamjan/tt-rss-service/releases/), into
`/var/lib/portables` and then run:

```sh
portablectl attach --enable --now tt-rss.raw
```

The service has to be configured in the `/etc/tt-rss/config.env` file before it's started, see bellow.
State will be kept in `/var/lib/private/tt-rss`.

The running service is available via the `/run/tt-rss.sock` uwsgi
socket that can be used in nginx.

## Configuration

The service is configured by the `/etc/tt-rss/config.env`, which is a simple `Key=Value` file that sets the process
environment. It is read by the [EnvironmentFile](https://www.freedesktop.org/software/systemd/man/systemd.exec.html#EnvironmentFile=)
directive in the service.

Example:
```
DB_TYPE=mysql
DB_HOST=localhost
DB_USER=tt-rss
DB_NAME=tt-rss
DB_PASS=tt-rss
DB_PORT=3306
SELF_URL_PATH=https://tt-rss.example.net
```


## How it's made

Look at `build.sh`, it's a shell script that builds a minimal ubuntu file-system with uwsgi, php and tt-rss included.
Then, on top of that, it adds the uwsgi config file, a tt-rss config file and the systemd service and socket units.
You can run the script locally too, it will generate `./tt-rss.raw` in the current directory.

To build locally, just run `sudo ./build.sh tt-rss.raw image-workdir` (it needs sudo for debootstrap). Then you can play
with the image with:

```
portablectl attach --runtime ./tt-rss.raw
systemctl cat tt-rss.service tt-rss.socket
systemctl start tt-rss.service
systemctl stop tt-rss.service
portablectl detach --runtime tt-rss
```
