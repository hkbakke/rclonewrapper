#!/bin/bash

MODE="${1}"
CONFIG="/etc/rclonewrapper/config.sh"
LOCAL="/"


print_usage () {
    echo "Usage: rclonewrapper.sh MODE"
    echo ""
    echo "arguments:"
    echo "    MODE          copy|sync"
}

rclone_sync () {
    rclone_copy
}

rclone_copy () {
    INCLUDE_CMD=()
    for INCLUDE in "${INCLUDES[@]}"; do
        INCLUDE_CMD+=( --include "${INCLUDE}" )
    done

    EXCLUDE_CMD=()
    for EXCLUDE in "${EXCLUDES[@]}"; do
        EXCLUDE_CMD+=( --exclude "${EXCLUDE}" )
    done

    (
        flock -n 9 || exit 1

        ${RCLONE} \
            "${INCLUDE_CMD[@]}" \
            "${EXCLUDE_CMD[@]}" \
            ${MODE} ${LOCAL} ${REMOTE} \
            "${RCLONE_OPTIONS[@]}"
    ) 9>${LOCKFILE}
}


source "${CONFIG}" || exit 1

if [[ ${MODE} == "copy" ]]; then
    rclone_copy
elif [[ ${MODE} == "sync" ]]; then
    rclone_sync
else
    print_usage
fi
