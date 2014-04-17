define jetty::instance::logrotate (
  $jetty_base,
  $interval,
  $rotation,
  $jetty_user = 'jetty',
) {

  $instance_name = $name

  logrotate::file { "jetty-${instance_name}":
    log          => "${jetty_base}/logs/jetty.log",
    interval     => $interval,
    rotation     => $rotation,
    options      => [ 'missingok', 'compress', 'notifempty', 'delaycompress', 'sharedscripts' ],
    archive      => true,
    olddir       => "${jetty_base}/logs/archives",
    olddir_owner => 'root',
    olddir_group => 'super',
    olddir_mode  => '644',
    create       => "644 ${jetty_user} ${jetty_user}",
    postrotate   => "if [ -f \"`. /etc/default/jetty-${instance_name} ; echo \${JETTY_PID:-/var/run/jetty-${instance_name}.pid}`\" ]; then
                      /etc/init.d/jetty-${instance_name} restart > /dev/null
                      fi";
  }
}
