IMAGE ?= idl:0.1.0

build:
	docker build . -t $(IMAGE) -f Dockerfile

idl: 
	 docker run --name test_idl -it $(IMAGE) /usr/local/harris/idl/bin/idl
