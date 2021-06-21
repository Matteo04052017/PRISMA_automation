
PRISMA_DB_VER=0.1.0
WEBSERVER_VER=0.1.0
SYNC_FRIPON_VER=0.1.0
PRISMA_DRIVER_VER=0.1.0
SYNC_FRIPON_VER=0.1.0

build_idl:
	@cd idl && make build && cd ..

submodule:
	@git submodule update --init --recursive

build_driver: submodule 
	@docker build . -t prismadriver:$(PRISMA_DRIVER_VER) -f docker/Dockerfile.driver

build_prisma_db: submodule
	@docker build . -t prismadb:$(PRISMA_DB_VER) -f docker/Dockerfile.db

build_webserver: submodule
	@docker build . -t webserver:$(WEBSERVER_VER) -f docker/Dockerfile.www

build_sync_fripon: submodule
	@docker build . -t sync_fripon:$(SYNC_FRIPON_VER) -f docker/Dockerfile.sync

build: submodule build_idl build_driver build_sync_fripon build_prisma_db build_webserver

start_idl:
	docker-compose -f docker-compose-idl.yml up -d --remove-orphans

stop_idl:
	docker-compose -f docker-compose-idl.yml down --remove-orphans

start_sync:
	docker-compose up -d --remove-orphans

stop_sync:
	docker-compose down --remove-orphans

vars:
	@echo "MYSQL_USER=$(MYSQL_USER)"
	@echo "MYSQL_PASSWORD=$(MYSQL_PASSWORD)"
	@echo "MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD)"

