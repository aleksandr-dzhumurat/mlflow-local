CURRENT_DIR = $(shell pwd)
PROJECT_NAME = mlflow
NETWORK_NAME = service_network
include .env
export


build-network:
	docker network create ${NETWORK_NAME} -d bridge || true

prepare-dirs:
	mkdir -p ${CURRENT_DIR}/data/artifacts || true && \
	mkdir -p ${CURRENT_DIR}/data/minio || true

build-mlflow: prepare-dirs build-network
	docker build -f Dockerfile -t adzhumurat/${PROJECT_NAME}:local .

build-minio:
	docker build -f Dockerfile.minio -t minio:dev .

run-mlflow:
	docker run -d --rm \
		--env-file ${CURRENT_DIR}/.env  \
		--network ${NETWORK_NAME} \
		-p "${MLFLOW_PORT}:${MLFLOW_PORT}" \
	    -v "${CURRENT_DIR}/data:${MLFLOW_HOME}" \
	    --name ${PROJECT_NAME}_container_ui \
		adzhumurat/${PROJECT_NAME}:local \
		serve

run-minio:
	docker run -d --rm \
		--env-file ${CURRENT_DIR}/.env  \
		--network ${NETWORK_NAME} \
		-p "${MINIO_PORT}:9001" \
		-e MINIO_ROOT_USER=${AWS_ACCESS_KEY_ID} \
		-e MINIO_ROOT_PASSWORD=${AWS_SECRET_ACCESS_KEY} \
	    -v "${CURRENT_DIR}/data/minio:/data" \
	    --name s3 \
		minio:dev

stop-mlflow:
	docker rm -f ${PROJECT_NAME}_container_ui

stop-minio:
	docker rm -f s3

build-jupyter: prepare-dirs
	docker build -f Dockerfile.jupyter -t ${PROJECT_NAME}:jupyter .

stop-jupyter:
	docker rm -f ${PROJECT_NAME}_jupyter_container

push-ui: build-ui-prod
	docker push adzhumurat/${PROJECT_NAME}_ui:local

run-jupyter: stop-jupyter build-jupyter
	docker run -d --rm \
	    --env-file ${CURRENT_DIR}/.env \
	    -p ${PORT_JUPYTER}:8888 \
	    -v "${CURRENT_DIR}/src:/srv/src" \
	    -v "${CURRENT_DIR}/data:/srv/data" \
		--network service_network \
	    --name ${PROJECT_NAME}_jupyter_container \
	    ${PROJECT_NAME}:jupyter

build:  build-mlflow build-jupyter build-minio

stop: stop-mlflow stop-jupyter stop-minio

run-all: run-mlflow run-minio run-jupyter

run: stop run-all

clean:
	docker image rm -f adzhumurat/${PROJECT_NAME}_api:latest && \
	docker image rm -f adzhumurat/${PROJECT_NAME}_ui:local
