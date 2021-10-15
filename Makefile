REPO      ?= gianlu33/reactive-base
TAG       ?= latest

PWD        = $(shell pwd)
VOLUME    ?= $(PWD)

run:
	docker run --rm -it --network=host -v $(VOLUME):/usr/src/app/ $(REPO):$(TAG) bash

pull:
	docker pull $(REPO):$(TAG)

build:
	docker build -t $(REPO):$(TAG) .

push: login
	docker push $(REPO):$(TAG)

login:
	docker login

clean:
	docker rm $(shell docker ps -a -q) 2> /dev/null || true
	docker image prune -f
