# duckdns-dehydrated
This is a docker image used to create certificates from Let's encrypt using dehydrate.
DuckDNS is used as a dynamic DNS resolver for the challenge generated by Let's encrypt.

## Running the container
The most comfortable way of running the container is using docker-compose
``` yaml
version: '3'
services:
  dehydrated-duckdns:
    image: duckdns-dehydrated
    build:
      context: .
      dockerfile: Dockerfile
    container_name: dehydrated-duckdns
    restart: unless-stopped
    volumes:
      - ./data:/data
    environment:
      - DUCKDNS_TOKEN=token
      - CRON_SCHEDULE=0 0 */7 * * # (default)
      - MAIN_DOMAIN=yourdomain.duckdns.org
      - SUBDOMAINS=*.yourdomain.duckdns.org
      - DEHYDRATED_CONTACT_EMAIL=yourmail@mail.com
      - DEHYDRATED_CA=letsencrypt-test #(default: letsencrypt)
      - FORCE_RUN=true # (default: false)
```
The account and certificate data is stored in `data`.

Instead of solving challenges for the domain and subdomain at the same time the generation process is split for every subdomain.
The reason for this is that duckDNS allows only one DNS TXT entry on the domain.

Every dehydrated config environmental variable can be modified by passing `DEHYDRATED_{variable}` as an environmental variable in the compose file. 

## Prerequisites
 - A DuckDNS account
 - Docker