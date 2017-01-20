#!/bin/sh
# Cleanup docker files: untagged containers and images.
#
# Use `docker-cleanup -n` for a dry run to see what would be deleted.

get_exited_containers() {
  docker ps -a -q -f status=exited
}

get_untagged_containers() {
    # Print containers using untagged images: $1 is used with awk's print: 0=line, 1=column 1.
    # NOTE: "[0-9a-f]{12}" does not work with GNU Awk 3.1.7 (RHEL6).
    # Ref: https://github.com/blueyed/dotfiles/commit/a14f0b4b#commitcomment-6736470
    docker ps -a | tail -n +2 | awk '$2 ~ "^[0-9a-f]+$" {print $'$1'}'
}

get_all_containers() {
    docker ps -aq
}

get_untagged_images() {
    # Print untagged images: $1 is used with awk's print: 0=line, 3=column 3.
    # NOTE: intermediate images (via -a) seem to only cause
    # "Error: Conflict, foobarid wasn't deleted" messages.
    # Might be useful sometimes when Docker messed things up?!
    # docker images -a | awk '$1 == "<none>" {print $'$1'}'
    docker images | tail -n +2 | awk '$1 == "<none>" {print $'$1'}'
}

get_all_images() {
    docker images -aq
}

get_untagged_volumes() {
    docker volume ls -qf dangling=true
}

all=false
force=false
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -a|--all)
            all=true
            shift
            ;;
        -f|--force)
            force=true
            shift
            ;;
        -h|--help|-?)
            echo "Cleanup docker files: remove containers, images, and volumes."
            echo "Usage: ${0##*/} [-a] [-f]"
            echo " -f | --force:      force removal (dry run by default)."
            echo " -a | --all:        remove EVERYTHING"
            echo " -h | --help | -?:  display this message and exit"
            exit 1
            ;;
    esac
done

if [ "$force" = true ]; then
    if [ "$all" = true ]; then
        # Remove all containers and volumes
        echo "Removing all containers and their volumes"
        all_containers=$(get_all_containers)
        if [ -n "$all_containers" ]; then
            docker rm -v $all_containers
        fi

        # Remove all images
        echo "Removing all images"
        all_images=$(get_all_images)
        if [ -n "$all_images" ]; then
            docker rmi -f $all_images
        fi
    else
        # Remove exited containers
        echo "Removing exited containers:" >&2
        exited_containers=$(get_exited_containers)
        if [ -n "$exited_containers" ]; then
            docker rm -v $exited_containers
        fi

        # Remove containers with untagged images.
        echo "Removing containers:" >&2
        untagged_containers=$(get_untagged_containers 1)
        if [ -n "$untagged_containers" ]; then
            docker rm --volumes=true $untagged_containers
        fi

        # Remove untagged images
        echo "Removing images:" >&2
        untagged_images=$(get_untagged_images 3)
        if [ -n "$untagged_images" ]; then
            docker rmi $untagged_images
        fi

        # Remove untagged volumes
        echo "Removing volumes:" >&2
        untagged_volumes=$(get_untagged_volumes)
        if [ -n "$untagged_volumes" ]; then
            docker volume rm $untagged_volumes
        fi
    fi
else
    if [ "$all" = true ]; then
        echo "=== Containers: ==="
        get_all_containers
        echo
        echo "=== Images: ==="
        get_all_images
    else
        echo "=== Exited containers: ==="
        get_exited_containers
        echo
        echo "=== Containers with uncommitted images: ==="
        get_untagged_containers 0
        echo
        echo "=== Uncommitted images: ==="
        get_untagged_images 0
        echo
        echo "=== Untagged volumes: ==="
        get_untagged_volumes
    fi
    exit
fi


# Remove exited containers
echo "Removing exited containers:" >&2
exited=$(get_exited_containers)
if [ -n "$exited" ]; then
    docker rm -v $exited
fi

# Remove containers with untagged images.
echo "Removing containers:" >&2
with_untagged_i=$(get_untagged_containers 1)
if [ -n "$with_untagged_i" ]; then
    docker rm --volumes=true $with_untagged_i
fi

# Remove untagged images
echo "Removing images:" >&2
untagged_i=$(get_untagged_images 3)
if [ -n "$untagged_i" ]; then
    docker rmi $untagged_i
fi

# Remove untagged volumes
echo "Removing volumes:" >&2
untagged_v=$(get_untagged_volumes)
if [ -n "$untagged_v" ]; then
    docker volume rm $untagged_v
fi
