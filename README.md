# Development environment for kong and kong-plugins with docker and docker-compose

## Goal

It's hard to set up a development environment for kong plugins based on documentation available on their website,
so here i boil down everything into a dockerfile and docker-compose files to get all sources dependencies, services and
environment configuration setup properly.

Also i provide an updated version of the kafka-log plugin created by [@yskopets](https://github.com/yskopets/kong-plugin-kafka-log) as an example
of a plugin with some pseudo and simple integration-testing i setup to update the plugin with latest kong (1.3.x) and lua-kafka-resty (0.07) dependencies.

## prerequisites

- docker
- docker-compose

# How to use

## Initial Test
```bash

git clone https://github.com/s3ni0r/kong-plugins-development.git

cd kong-plugins-development

# Creates kong-dev, postgres, cassandra, redis, kafka and zookeeper containers
docker-compose up -d

# Gives you a shell interface into kong-dev container
docker exec -it kong-dev bash

# Runs integration test for the kafka-log example plugin
bin/busted -v spec/01-integration_spec.lua

```

## Developpement

The kong-plugin-kafka-log directory in the cloned repository is mounted into kong docker container at `/workspace/kong-plugin-kafka-log`,
so that you can edit files from your host machine via your favorite editor and then test it in the container using :

```bash
# Get a shell in the kong-dev container
docker exec -it kong-dev bash
# Run tests
bin/busted -v /spec/your_new_test.lua
```

## Configuration

The docker-compose file creates a postgres and cassandra containers which are configured in kong_tests.conf in the plugins
spec folder, there you can tweak it to fit your needs.

Enjoy :).