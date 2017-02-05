#!/bin/bash

MODE="${1}"
CONFIG="/etc/rclonewrapper/config.sh"


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
    (
        flock -n 9 || exit 1

        ${RCLONE} \
            ${MODE} \
            --filter-from "${FILTERFILE}" \
            ${LOCAL} ${REMOTE} \
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
