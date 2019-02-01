#!/bin/sh

_exit_with_error() {
    echo >&2 $1;
    exit 1;
}

backup() {
    BACKUP_NAME="ghost_backup_$(date +%Y_%m_%d)"
    zip -r $BACKUP_NAME ./ghost/content ./ghost/db.sqlite
}

generate() {
    if [ ! -f ./CNAME ]; then
        read -p "Enter the production URL (e.g. https://myblog.com): " PRODUCTION_URL
        echo "$PRODUCTION_URL" > "./CNAME"
    else
        read -r PRODUCTION_URL<CNAME
    fi
    rm -rf ./static
    node_modules/ghost-static-site-generator/src/index.js --domain "http://localhost:2373" --url "$PRODUCTION_URL"
    cp CNAME ./static/CNAME
}

install() {
	# Checking nodejs
	if ! command -v node >/dev/null 2>&1; then
        _exit_with_error "nodejs is not installed.\nAborting.";
	fi
	# https://docs.ghost.org/faq/node-versions/
	# 6.x, 8.x, 10.x
	NODE_VERSION="$(node --version)"
	if [[ "$NODE_VERSION" != v6.* && "$NODE_VERSION" != v8.* && "$NODE_VERSION" != v10.* ]]; then
		_exit_with_error "this version of nodejs (${NODE_VERSION}) is not compatible. \nhttps://docs.ghost.org/faq/node-versions \nAborting.";
	fi
	npm install ghost-cli@latest ghost-static-site-generator
	if [ -d ghost ]; then
		echo >&2 "ghost folder already exists. Skipping initialization.";
	else
		mkdir -p ghost
		node_modules/ghost-cli/bin/ghost install local --no-start --enable --port 2373 --dir ./ghost --url localhost:2373 --db sqlite3 --dbpath $(pwd)/ghost/db.sqlite
	fi
}

list() {
    node_modules/ghost-cli/bin/ghost ls
}

push() {
	if [ ! -d static ]; then
		_exit_with_error "no static folder. Please generate one.\nAborting.";
	fi
	if [ -z "$(ls -A ./static)" ]; then
		_exit_with_error "static folder is empty.\nAborting.";
	fi
	if [ ! -d .git ]; then
		_exit_with_error "not in a git repository.\nAborting.";
	fi
	if git remote | grep -vq 'origin'; then
		_exit_with_error "no remote/origin branch.\nAborting.";
	fi
	GIT_REPO_URL=$(git config --get remote.origin.url)
	if [ -z "$(git config user.name)" ]; then
	  git config user.name "ghostpages.sh"
	fi
	GIT_REPO_USERNAME=$(git config --get user.name)
	if [ -z "$(git config user.email)" ]; then
	  git config user.email "ghostpages.sh@script"
	fi
	GIT_REPO_EMAIL=$(git config --get user.email)
	cd static
	rm -rf .git ; git init .
	git config user.name $GIT_REPO_USERNAME
	git config user.email $GIT_REPO_EMAIL
	git remote add github $GIT_REPO_URL
	git checkout -b gh-pages
	git add . ; git commit -am "Publish to gh-pages [ghostpages.sh]"
	git push github gh-pages --force
	rm -rf .git
	cd ..
}

run() {
    node_modules/ghost-cli/bin/ghost start --dir ./ghost
}

case "$1" in
    "backup"|"b")
        backup
    ;;
    "generate"|"gen"|"g")
        generate
    ;;
    "install"|"i")
        install
        run
    ;;
    "list"|"l")
        list
    ;;
    "push"|"publish"|"deploy"|"p")
        push
    ;;
    "run"|"r")
        run
    ;;
    *)
        echo "unknown command"
        echo "Syntax : \n"
        echo "    ghostpages.sh [options]\n"
        echo "Options : \n"
        echo "    backup | b"
        echo "    generate | gen | g"
        echo "    install | i"
        echo "    list | l"
        echo "    publish | push | p | deploy"
        echo "    run | r"
        exit 1
    ;;
esac
