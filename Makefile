
PRISMA_DB_VER=0.1.0
WEBSERVER_VER=0.1.0
SYNC_FRIPON_VER=0.1.0
PRISMA_DRIVER_VER=0.1.0
SYNC_FRIPON_VER=0.1.0

clean: 
	@rm -rf __pycache__/*.pyc venv build .pytest_cache __pycache__ src/*/__pycache__ src/*/*/__pycache__ tests/*/__pycache__ tests/*/*/__pycache__

build_idl:
	@cd idl && make build && cd ..

# submodule:
# 	@git submodule update --init --recursive

build_driver: 
	@docker build . -t prismadriver:$(PRISMA_DRIVER_VER) -f docker/Dockerfile.driver

build_sync_fripon:
	@docker build . -t sync_fripon:$(SYNC_FRIPON_VER) -f docker/Dockerfile.sync

build: build_idl build_driver build_sync_fripon

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

apply-formatting: # apply formatting with black
	isort --recursive --profile black src/ tests/
	black --line-length 79 src/ tests/

unit_test: ## Run simulation mode unit tests
	@mkdir -p build; \
	PYTHONPATH=src:src/prisma pytest  $(FILE)

lint: ## Linting src and tests directory
	@mkdir -p build/reports;
	isort --recursive --check-only --profile black src/ tests/
	black --line-length 79 --check src/ tests/
	flake8 --show-source --statistics src/ tests/
	pylint --rcfile=.pylintrc --output-format=parseable src/* tests/* | tee build/code_analysis.stdout
	pylint --output-format=pylint_junit.JUnitReporter src/* tests/* > build/reports/linting-python.xml