## start migration
# descomente quando for necessário
# include .env.example
# export
CURRENTNAME=$(shell pwd | sed 's!.*/!!')
OLDNAME=TCTemplateBack


## end 

VERSION = $(shell git branch --show-current)

.PHONY: help
help:  ## show this help
	@echo "usage: make [target]"
	@echo ""
	@egrep "^(.+)\:\ .*##\ (.+)" ${MAKEFILE_LIST} | sed 's/:.*##/#/' | column -t -c 2 -s '#'

.PHONY: rename
rename: 
	@echo Renomeando projeto de $(OLDNAME) para $(CURRENTNAME)
	@find . -type f -exec sed -i -e 's/$(OLDNAME)/$(CURRENTNAME)/g' {} \;
	@echo Sucesso!
	
.PHONY: run
run: ## run it will instance server 
	VERSION=$(VERSION) go run main.go

.PHONY: run-watch
run-watch: ## run-watch it will instance server with reload
	VERSION=$(VERSION) nodemon --exec go run main.go --signal SIGTERM

.PHONY: docs
docs: ## docs is a command to generate doc with swagger
	swag init

.PHONY: bump-deps
bump-deps: ## Update all dependencies
	go get -t -u ./...
	go mod tidy -compat=1.18


# ------------------------------------ migration ------------------------------------


helm-docs: ## Create helm Docs for chart
	./scripts/helm-docs.sh

.PHONY: cluster-local
cluster-local: ## Create cluster-local chart
	cd hack
	./hack/kind.sh --cluster-name dev-cluster --k8s-release 1.26.6 
