# Packages needed for your current development needs are defined in Makefile.site
# See Makefile.site.example
-include Makefile.site

# Use "docker build --no-cache" to rebuild the layers involving network (git clone, etc)

all:
# Use this to debug individual parts of the build process (the image IDs of intermediate steps are available
#	DOCKER_BUILDKIT=0 docker build --no-cache ...
	docker build --progress=plain        \
	  --build-arg USER_UID=$$(id -u)     \
	  --build-arg USER_GID=$$(id -g)     \
	  --build-arg DEV_PKGS="$(DEV_PKGS)" \
	  --build-arg APT_PROXY=http://172.17.0.1:3142 \
	  -t vim-ttsiodras:latest .
	echo "To remove the non-necessary wasted Docker space:"
	echo "    docker builder prune" 
	echo "    docker system prune"
