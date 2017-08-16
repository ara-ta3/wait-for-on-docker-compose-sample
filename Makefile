DOCKER_COMPOSE=$(shell which docker-compose)
MIGRATE=bin/migrate
mysql_db=test
user=root
pass=root
host=127.0.0.1
port=3306
database=mysql://$(user):$(pass)@tcp($(host):$(port))/$(mysql_db)?x-migrations-table=migrate_schema_versions
dirs=tmp bin

start:
	$(MAKE) install
	/opt/wait-for db:3306 -- $(MAKE) migrate/up
	bash

start/fail:
	$(MAKE) install
	$(MAKE) migrate/up

success:
	$(MAKE) docker/start conf=success.yml

success/clean:
	$(MAKE) docker/clean conf=success.yml

fail:
	$(MAKE) docker/start conf=fail.yml

fail/clean:
	$(MAKE) docker/clean conf=fail.yml

docker/start:
	$(DOCKER_COMPOSE) -f $(conf) build
	$(DOCKER_COMPOSE) -f $(conf) up

docker/clean:
	$(DOCKER_COMPOSE) -f $(conf) stop
	$(DOCKER_COMPOSE) -f $(conf) rm

name=
# gnu xargs only
# for mac. please install findutils
migrate/new:
	$(MIGRATE) -path ./migrations -database '$(database)' version 2>&1| gxargs -iV expr V + 1 |gxargs -iV touch V_$(name).up.sql

migrate/status: 
	$(MIGRATE) -path ./migrations -database '$(database)' version

n=
migrate/up: 
	$(MIGRATE) -path ./migrations -database '$(database)' -verbose up $(n)

version=
migrate/force:
	$(MIGRATE) -path ./migrations -database '$(database)' -verbose force $(version)

install: $(MIGRATE)

VERSION=v3.0.1
OS_TYPE=$(shell echo $(shell uname) | tr A-Z a-z)
OS_ARCH=amd64
$(MIGRATE): $(dirs)
	cd $< && curl -L https://github.com/mattes/migrate/releases/download/$(VERSION)/migrate.$(OS_TYPE)-$(OS_ARCH).tar.gz | tar xvz
	mv $</migrate.$(OS_TYPE)-$(OS_ARCH) $(MIGRATE)

$(dirs):
	mkdir $@
