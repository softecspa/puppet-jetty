# Define: jetty::instance
#
# This define creates a jetty instance
#
# Parameters:
#
# [*instance_name*]
#   name of jetty instance. Instance will be called jetty-$instance_name. If not present <name> will be used
#
# [*version*]
#   Version of jetty to install. Mandatory
#
# [*package_s3_bucket*]
#   Name of s3 bucket where jetty install is stored
#
# [*package_download_url*]
#   Url where jetty can be downloaded
#
# [*root*]
#   Root path where jetty will be installed. Default: /opt
#
# [*user*]
#   User for jetty process. Default: jetty
#
# [*user_uid*]
#   Uid for jetty user. Default: unset
#
# [*user_gid*]
#   Gid for jetty user. Default: unset
#
# [*service_startup*]
#   True is instance must be running. Default: true
#
# [*jetty_args*]
#   Variable JETTY_ARGS used in /etc/default/jetty-${instance_name}
#
# [*java_options*]
#   JAVA_OPTIONS to use in jetty instance
#
# [*jetty_base*]
#   JETTY_BASE for jetty instance. Default: ${root}/jetty-${instance_name}
#
# [*listen*]
#   listen_address of jetty instance. Default: 0.0.0.0
#
# [*logdir*]
#   directory where jetty logs are stored. Default: /var/log/jetty/${instance_name}
#
# [*pidfile*]
#   path of pid file. Default /var/run/jetty-${instance_name}.pid
#
# [*port*]
#   listen port. Mandatory
#
# [*logrotate_interval*]
#   interval for logrotate. Default: daily
#
# [*logrotate_rotation*]
#   Data retention for logrotate. Default: 30
#
define jetty::instance (
  $instance_name        = '',
  $version,
  $package_s3_bucket    = '',
  $package_download_url = '',
  $root                 = '/opt',
  $user                 = 'jetty',
  $user_uid             = undef,
  $user_gid             = undef,
  $service_startup      = true,
  $jetty_args           = '',
  $java_options         = '',
  $jetty_base           = '',
  $listen               = '0.0.0.0',
  $logdir               = '',
  $pidfile              = '',
  $port,
  $logrotate_interval   = 'daily',
  $logrotate_rotation   = '30',
) {

  $in = $instance_name?{
    ''      => $name,
    default => $instance_name,
  }

  $real_jetty_base = $jetty_base?{
    ''      => "${root}/jetty-${in}",
    default => $jetty_base,
  }

  $real_logdir  = $logdir? {
    ''      => "/var/log/jetty/$in",
    default => $logdir
  }

  $real_pidfile = $pidfile? {
    ''      => "/var/run/jetty-${in}.pid",
    default => $pidfile,
  }

  if !defined(Jetty::Version[$version]) {
    jetty::version {$version:
      package_s3_bucket     => $package_s3_bucket,
      package_download_url  => $package_download_url,
      root                  => $root,
      user                  => $user,
      user_uid              => $user_uid,
      user_gid              => $user_gid,
    }
  }

  jetty::instance::install {$name:
    version       => $version,
    instance_name => $in,
    jetty_base    => $real_jetty_base,
    user          => $user
  }

  jetty::instance::config {$name:
    version         => $version,
    instance_name   => $in,
    listen          => $listen,
    jetty_args      => $jetty_args,
    java_options    => $java_options,
    user            => $user,
    jetty_home      => "${root}/jetty-${version}",
    jetty_base      => $real_jetty_base,
    logdir          => $real_logdir,
    pidfile         => $real_pidfile,
    port            => $port
  }

  jetty::instance::service{$name:
    instance_name   => $in,
    service_startup => $service_startup,
  }

  jetty::instance::logrotate {$in:
    jetty_base  => $real_jetty_base,
    jetty_user  => $user,
    interval    => $logrotate_interval,
    rotation    => $logrotate_rotation
  }

  Jetty::Instance::Install[$name] ->
  Jetty::Instance::Config[$name] ->
  Jetty::Instance::Service[$name] ->
  Jetty::Instance::Logrotate[$name]

}
