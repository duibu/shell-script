#!/bin/bash
SHUTDOWN_WAIT=20
tomcatDir=/opt/tomcat/

export CATALINA_BASE=$tomcatDir
export CATALINA_HOME=$CATALINA_BASE
export JAVA_OPTS="-server -d64 -Djava.awt.headless=true -Xms2G -Xmx2G  -Xmn700m -XX:PermSize=128m -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC -XX:+UseCMSCompactAtFullCollection  -XX:CMSMaxAbortablePrecleanTime=5000 -XX:CMSInitiatingOccupancyFraction=80  -XX:+DisableExplicitGC  -XX:+CMSClassUnloadingEnabled -XX:+PrintGCDetails -XX:+PrintGCTimeStamps  -Djava.net.preferIPv4Stack=true -Dorg.apache.catalina.session.StandardSession.ACTIVITY_CHECK=true"

tomcat_pid() {
  echo `ps aux | grep $CATALINA_HOME | grep -v grep | awk '{ print $2 }'`
}

start() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
     then
        echo "Tomcat is already running (pid: $pid)"
     else
        echo "Starting Tomcat..."
        echo "Startup Script: $CATALINA_HOME/bin/startup.sh"
        $CATALINA_HOME/bin/startup.sh
   fi

   return 0
}

stop() {
 pid=$(tomcat_pid)
  if [ -n "$pid" ]
  then

  echo "Stoping Tomcat"
   $CATALINA_HOME/bin/shutdown.sh

   echo -n "Waiting for processes to exit ["
   let kwait=$SHUTDOWN_WAIT
    count=0;
    until [ `ps -p $pid | grep -c $pid` = '0' ] || [ $count -gt $kwait ]
  do
      echo -n ".";
      sleep 1
      let count=$count+1;
    done
    echo "Done]"

    if [ $count -gt $kwait ]
    then
      echo "Killing processes ($pid) which didn't stop after $SHUTDOWN_WAIT seconds"
      kill -9 $pid
    fi
  else
    echo "Tomcat is not running"
  fi

  return 0
}

status() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
  then
    echo "Tomcat is running with pid: $pid"
  else
    echo "Tomcat is not running"
  fi
}


case "$1" in
 start)
        start
        ;;
 stop)
        stop
        ;;
 restart)
       stop
       start
       ;;
 status)
       status
       ;;
*)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
exit 0