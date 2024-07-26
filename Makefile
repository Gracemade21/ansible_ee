name = ee-onbase-deployment-automation-rhel9
version = latest

all: build

build:
	ansible-builder build --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN -t $(name)

clean:
	rm -rf context

save:
	docker image save -o $(name)-$(version).tar $(name):$(version)
	gzip -9 $(name)-$(version).tar

.PHONY: build clean save
