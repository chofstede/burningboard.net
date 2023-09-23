#!/bin/sh

docker compose -f /opt/mastodon/docker-compose.yml run --rm web bin/tootctl media remove
docker compose -f /opt/mastodon/docker-compose.yml run --rm web bin/tootctl preview_cards remove
