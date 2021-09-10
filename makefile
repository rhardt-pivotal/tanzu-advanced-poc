build:
	TAG=`git rev-parse --short=8 HEAD`; \
	docker build --rm -f tanzu-advanced-poc.dockerfile -t tanzu-advanced-poc:$$TAG .; \
	docker tag tanzu-advanced-poc:$$TAG tanzu-advanced-poc:latest

clean:
	docker stop tanzu-advanced-poc
	docker rm tanzu-advanced-poc

rebuild: clean build

run:
	docker run --name tanzu-advanced-poc -v $$PWD/deploy:/deploy -v $$PWD/config/kube.conf:/root/.kube/config -td tanzu-advanced-poc:latest
	docker exec -it tanzu-advanced-poc bash -l

join:
	docker exec -it tanzu-advanced-poc bash -l

start:
	docker start tanzu-advanced-poc

stop:
	docker stop tanzu-advanced-poc

default: build
