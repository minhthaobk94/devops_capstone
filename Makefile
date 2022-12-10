#Vars
CLUSTER_NAME=thaoapp
REGION_NAME=us-east-1
KEYPAIR_NAME=udacity
DEPLOYMENT_NAME=thaoapp
NEW_IMAGE_NAME=registry.hub.docker.com/minhthaobk94/thaoapp:latest
CONTAINER_PORT=80
HOST_PORT=8080
KUBECTL=./bin/kubectl

setup:
	python -m venv venv
	#source ./venv/bin/activate

install:
	# this should be run from inside a virtualenv
	echo "Installing dependencies..."
	pip install --upgrade pip && pip install -r thaoapp/requirements.txt
	echo
	pytest --version
	echo
	echo "Installing shellcheck..."
	./bin/install_shellcheck.sh
	echo
	echo "Installing hadolint..."
	./bin/install_hadolint.sh
	echo
	echo "Installing kubectl..."
	./bin/install_kubectl.sh
	echo
	echo "Installing eksctl..."
	./bin/install_eksctl.sh

test:
	# python -m pytest -vv thaoapp/thaoapp.py

lint:
	# https://github.com/koalaman/shellcheck: a linter for shell scripts
	./bin/shellcheck -Cauto -a ./bin/*.sh
	# https://github.com/hadolint/hadolint: a linter for Dockerfiles
	./bin/hadolint thaoapp/Dockerfile
	# https://www.pylint.org/: a linter for Python source code 
	pylint --output-format=colorized --disable=C thaoapp/thaoapp.py

run-app:
	python thaoapp/thaoapp.py

build-docker:
	./bin/build_docker.sh

run-docker: build-docker
	./bin/run_docker.sh

upload-docker: build-docker
	./bin/upload_docker.sh

ci-validate:
	# Required file: .circleci/config.yml
	circleci config validate

k8s-deployment: eks-create-cluster
	# If using minikube, first run: minikube start
	./bin/k8s_deployment.sh

port-forwarding: 
	# Needed for "minikube" only
	${KUBECTL} port-forward service/${DEPLOYMENT_NAME} ${HOST_PORT}:${CONTAINER_PORT}

rolling-update:
	${KUBECTL} get deployments -o wide
	${KUBECTL} set image deployments/${DEPLOYMENT_NAME} \
		${DEPLOYMENT_NAME}=${NEW_IMAGE_NAME}
	echo
	${KUBECTL} get deployments -o wide
	${KUBECTL} describe pods | grep -i image
	${KUBECTL} get pods -o wide

rollout-status:
	${KUBECTL} rollout status deployment ${DEPLOYMENT_NAME}
	echo
	${KUBECTL} get deployments -o wide

rollback:
	${KUBECTL} get deployments -o wide
	${KUBECTL} rollout undo deployment ${DEPLOYMENT_NAME}
	${KUBECTL} describe pods | grep -i image
	echo
	${KUBECTL} get pods -o wide
	${KUBECTL} get deployments -o wide

k8s-cleanup-resources:
	./bin/k8s_cleanup_resources.sh

eks-create-cluster:
	./bin/eks_create_cluster.sh

eks-delete-cluster:
	./bin/eksctl delete cluster --name "${CLUSTER_NAME}" \
		--region "${REGION_NAME}"