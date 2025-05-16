all:
	docker build --no-cache \
	  --build-arg USER_UID=$$(id -u) \
	  --build-arg USER_GID=$$(id -g) \
	  -t vim-ttsiodras:latest .
