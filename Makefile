ifndef VERSION
$(error VERSION is not set)
endif

NAME = cogcmd/aws-cfn
TAG = $(NAME):$(VERSION)

.PHONY: build push deploy
.DEFAULT: build

build:
	docker build -t $(TAG) .

push: build
	docker push $(TAG)

release: push
	git tag $(VERSION)
	git push origin $(VERSION)
