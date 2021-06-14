#!/bin/bash
GROUP=2021-05
# BRANCH=${GITHUB_REF##*/}
HOMEWORK_RUN=./otus-homeworks/homeworks/$TRAVIS_BRANCH/run.sh
REPO=https://github.com/Gron44/otus-homeworks.git
DOCKER_IMAGE=express42/otus-homeworks:0.7.1

echo GROUP:$GROUP

if [ "$TRAVIS_BRANCH" == "" ]; then
	echo "We don't have tests for master branch"
	exit 0
fi

echo HOMEWORK:$TRAVIS_BRANCH
ls -alh ./otus-homeworks/

find / -type d -name 'otus-homeworks' 2> /dev/null

if [ -f $HOMEWORK_RUN ]; then
	echo "Run tests"
	# Prepare network & run container
	docker network create hw-test-net
	docker run -d -v $(pwd):/srv -v /var/run/docker.sock:/tmp/docker.sock \
		-e DOCKER_HOST=unix:///tmp/docker.sock --cap-add=NET_ADMIN -p 33433:22 --privileged \
		--device /dev/net/tun --name hw-test --network hw-test-net $DOCKER_IMAGE
	# Show versions & run tests
	docker exec hw-test bash -c 'echo -=Get versions=-; ansible --version; ansible-lint --version; packer version; terraform version; tflint --version; docker version; docker-compose --version'
	docker exec -e USER=appuser -e BRANCH=$TRAVIS_BRANCH hw-test $HOMEWORK_RUN

	# ssh -i id_rsa_test -p 33433 root@localhost "cd /srv && BRANCH=$TRAVIS_BRANCH $HOMEWORK_RUN"
else
	echo "We don't have tests for this homework"
	exit 0
fi
