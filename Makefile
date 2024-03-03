# Makefile for docker/kubectl processes

SHELL := /bin/bash
.PHONY: build

build-all:
# Build & Push the webviewer
	docker build --platform=linux/amd64 -f webviewer.Dockerfile -t registry.rcd.clemson.edu/viprgs_v_n_v/hpc_cloud_solutions/webviewer:latest . && \
		docker push registry.rcd.clemson.edu/viprgs_v_n_v/hpc_cloud_solutions/webviewer:latest
# Build & Push the node backend
	cd ./node_server && docker build --platform=linux/amd64 -f node.Dockerfile -t registry.rcd.clemson.edu/viprgs_v_n_v/hpc_cloud_solutions/nodebackend:latest . && \
		docker push registry.rcd.clemson.edu/viprgs_v_n_v/hpc_cloud_solutions/nodebackend:latest && \
	kubectl -n carla-test delete pod $$(kubectl -n carla-test get pods -l=app=webapp -o jsonpath="{.items[*].metadata.name}")
build-backend:
# Build & Push the node backend
	cd ./node_server && docker build --platform=linux/amd64 -f node.Dockerfile -t registry.rcd.clemson.edu/viprgs_v_n_v/hpc_cloud_solutions/nodebackend:latest . && \
		docker push registry.rcd.clemson.edu/viprgs_v_n_v/hpc_cloud_solutions/nodebackend:latest && \
		kubectl -n carla-test delete pod $$(kubectl -n carla-test get pods -l=app=webapp -o jsonpath="{.items[*].metadata.name}")

build-frontend:
# Build & Push the webviewer
	docker build --platform=linux/amd64 -f webviewer.Dockerfile -t registry.rcd.clemson.edu/viprgs_v_n_v/hpc_cloud_solutions/webviewer:latest . && \
		docker push registry.rcd.clemson.edu/viprgs_v_n_v/hpc_cloud_solutions/webviewer:latest && \
		kubectl -n carla-test delete pod $$(kubectl -n carla-test get pods -l=app=webapp -o jsonpath="{.items[*].metadata.name}")