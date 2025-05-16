# Packages needed for my current development in C/C++
DEV_PKGS = uuid-dev libnl-route-3-dev  librdmacm-dev libnl-3-dev  libcap-dev  libpfm4-dev libboost-dev libboost-filesystem-dev libcurl4-openssl-dev libboost-program-options-dev libdrm-dev libdw-dev libelf-dev libffi-dev libgtest-dev libjson-glib-dev libncurses5-dev libsystemd-dev libmariadb-dev

# Use "docker build --no-cache" to rebuild the layers involving network (git clone, etc)

all:
	docker build --progress=plain        \
	  --build-arg USER_UID=$$(id -u)     \
	  --build-arg USER_GID=$$(id -g)     \
	  --build-arg DEV_PKGS="$(DEV_PKGS)" \
	  -t vim-ttsiodras:latest .
