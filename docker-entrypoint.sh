#!/bin/sh

set -e

USER_APP=jetty
GROUP_APP=jetty
DEFAULT_UID=`id -u $USER_APP`
DEFAULT_GID=`id -g $GROUP_APP`

if [ "x$EUID" != 'x' -a "$DEFAULT_UID" != "$EUID" ]; then
    echo Changing the UID of $USER_APP from $DEFAULT_UID to $EUID
    which usermod && usermod -u "$EUID" "$USER_APP" || sed -i "s/\($USER_APP:[^:]:\)$DEFAULT_UID:/\1$EUID:/g" /etc/passwd
    find / -xdev -user ${DEFAULT_UID} -exec chown ${EUID} {} \;
fi

if [ "x$EGID" != 'x' -a "$DEFAULT_GID" != "$EGID" ]; then
    echo Changing the GID of $GROUP_APP from $DEFAULT_GID to $EGID

    if [ "$(which groupmod)" ]; then
        groupmod -g "$EGID" "$GROUP_APP"
    else
        sed -i "s/\($GROUP_APP:[^:]:\)$DEFAULT_GID:/\1$EGID:/g" /etc/group
        sed -i "s/\([^:]*:[^:]:[^:]*:\)$DEFAULT_GID:/\1$EGID:/g" /etc/passwd
    fi
    find / -xdev -group ${DEFAULT_GID} -exec chgrp ${EGID} {} \;
fi

echo Launching $@...
exec su-exec "$USER_APP" /docker-entrypoint.sh $@