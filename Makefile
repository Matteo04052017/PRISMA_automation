
PRISMA_DB_VER=0.1.0
WEBSERVER_VER=0.1.0
SYNC_FRIPON_VER=0.1.0
PRISMA_DRIVER_VER=0.1.0
SYNC_FRIPON_VER=0.1.0

build_idl:
	@cd idl && make build && cd ..

submodule:
	@git submodule update --init --recursive

build_driver:
	@docker build . -t prismadriver:$(PRISMA_DRIVER_VER) -f docker/Dockerfile.driver

build_prisma_db:
	@docker build . -t prismadb:$(PRISMA_DB_VER) -f docker/Dockerfile.db

build_webserver:
	@docker build . -t webserver:$(WEBSERVER_VER) -f docker/Dockerfile.www

build_sync_fripon:
	@docker build . -t sync_fripon:$(SYNC_FRIPON_VER) -f docker/Dockerfile.sync

# run_prisma_db:
# 	@docker run --name prismadb prismadb:$(PRISMA_DB_VER) \
# 		-v /my/own/datadir:/var/lib/mysql \
# 		-p 3306:3306 -d \
# 		--env MYSQL_USER=$(MYSQL_USER) \
# 		--env MYSQL_PASSWORD=$(MYSQL_PASSWORD) \
# 		--env MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD) 

build: build_idl build_driver build_sync_fripon build_prisma_db build_webserver

# run_webserver:
# 	docker run --name webserver webserver:$(WEBSERVER_VER) -p 8080:80 

run:
	docker-compose up 

vars:
	@echo "MYSQL_USER=$(MYSQL_USER)"
	@echo "MYSQL_PASSWORD=$(MYSQL_PASSWORD)"
	@echo "MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD)"

