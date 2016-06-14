#!/bin/bash
#chkconfig: 2345 85 15
#description: h2o Web Server

RETVAL=0
SERVICE_NAME=`basename $0`
PROG=/usr/local/bin/h2o
CONF=/etc/h2o/h2o.conf
USER=www-data
GROUP=www-data

start() {
    if [ $"$PROG -t -c $CONF |grep OK" ]; then
        echo -n $"Starting $SERVICE_NAME: "
        mkdir -p /var/run/h2o
        mkdir -p /var/log/h2o
        chown $USER:$GROUP /var/run/h2o
        chown $USER:$GROUP /var/log/h2o
        $PROG -m daemon -c $CONF
        RETVAL=$?
        if [ $RETVAL == 0 ]; then
            echo success
        else
            echo failure
        fi
    else
        echo "failure configuration file."
        echo $"Not starting $SERVICE_NAME"
        RETVAL=1
    fi
}

stop() {
    echo -n $"Stopping $SERVICE_NAME: "
    kill -TERM `cat /var/run/h2o/h2o.pid`
    RETVAL=$?
    if [ $RETVAL == 0 ]; then
        echo success
    else
        echo failure
    fi
}

reload() {
    echo -n $"Graceful $SERVICE_NAME: "
    kill -HUP `cat /var/run/h2o/h2o.pid`
    RETVAL=$?
    if [ $RETVAL == 0 ]; then
        echo success
    else
        echo failure
    fi
}

status() {
    if [ -f "/var/run/h2o/h2o.pid" ]; then
        echo running with PID "`cat /var/run/h2o/h2o.pid`"
        RETVAL=0
    else
        echo stopped
        RETVAL=1
    fi
}

configtest() {
    echo -n $"ConfigTest $SERVICE_NAME: "
    $PROG -t -c $CONF
    RETVAL=$?
    if [ $RETVAL == 0 ]; then
        echo success
    else
        echo failure
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    reload|graceful)
        reload
        ;;
    restart)
        stop
        start
        ;;
    status)
        status
        ;;
    configtest)
        configtest
        ;;
    *)
        echo $"Usage: $0 {start|stop|reload|graceful|restart|status|configtest}"
        exit 1
esac

exit $RETVAL
