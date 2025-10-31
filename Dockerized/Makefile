# Packages needed for your current development needs. This is mine :-)
DEV_PKGS = \
    libboost-dev libboost-filesystem-dev libboost-program-options-dev libc6-dev libcap-dev \
    libcurl4-openssl-dev libdrm-dev libdw-dev libelf-dev libffi-dev libgtest-dev \
    libjpeg-dev libjson-glib-dev libmariadb-dev libncurses5-dev libncurses-dev \
    libnl-3-dev libnl-route-3-dev libnl-route-3-dev libopencv-core-dev libperl-dev \
    libpfm4-dev libpng-dev libprotoc-dev libpython3-dev libpython3-dev \
    librdmacm-dev libssl-dev libsystemd-dev libtiff5-dev libtool libudev-dev \
    libyaml-dev linux-libc-dev moreutils ocl-icd-dev ocl-icd-opencl-dev pkg-config \
    pkg-config protobuf-compiler rapidjson-dev uuid-dev uuid-dev zlib1g-dev

# e.g.
# DEV_PKGS = uuid-dev libnl-route-3-dev  librdmacm-dev libnl-3-dev  libcap-dev  libpfm4-dev libboost-dev libboost-filesystem-dev libcurl4-openssl-dev libboost-program-options-dev libdrm-dev libdw-dev libelf-dev libffi-dev libgtest-dev libjson-glib-dev libncurses5-dev libsystemd-dev libmariadb-dev

# Use "docker build --no-cache" to rebuild the layers involving network (git clone, etc)

all:
	docker build --progress=plain        \
	  --build-arg USER_UID=$$(id -u)     \
	  --build-arg USER_GID=$$(id -g)     \
	  --build-arg DEV_PKGS="$(DEV_PKGS)" \
	  -t vim-ttsiodras:latest .
	echo "To remove the non-necessary wasted Docker space:"
	echo "    docker builder prune" 
	echo "    docker system prune"
