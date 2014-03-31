define jetty::version (
  $version              = '',
  $package_s3_bucket    = '',
  $package_download_url = '',
  $root                 = '/opt',
  $user                 = 'jetty',
  $user_uid             = undef,
  $user_gid             = undef,
  $service_startup      = false,
  $jetty_args           = '',
  $java_options         = '',
  $jetty_home           = '',
  $jetty_base           = '',
  $listen               = '0.0.0.0',
  $logdir               = '',
  $pidfile              = '',
) {

  $real_version = $version?{
    ''      => $name,
    defalt  => $version
  }

  $real_jetty_home = $jetty_home?{
    ''      => "${root}/jetty-${real_version}",
    default => $jetty_home,
  }

  $real_jetty_base = $jetty_base?{
    ''      => $real_jetty_home,
    default => $jetty_base,
  }

  $real_logdir  = $logdir? {
    ''      => "/var/log/jetty/$real_version",
    default => $logdir
  }

  $real_pidfile = $pidfile? {
    ''      => "/var/run/jetty-${real_version}.pid",
    default => $pidfile,
  }

  if !defined(Class['java']) {
    class {'java':
      java_package  => 'openjdk-7-jre'
    }
  }

  jetty::version::install {$name:
    version               => $real_version,
    package_s3_bucket     => $package_s3_bucket,
    package_download_url  => $package_download_url,
    root                  => $root,
    user                  => $user,
    user_uid              => $user_uid,
    user_gid              => $user_gid,
  }

  jetty::version::config {$name:
    version         => $real_version,
    service_startup => $service_startup,
    jetty_args      => $jetty_args,
    java_options    => $java_options,
    user            => $user,
    jetty_home      => $real_jetty_home,
    jetty_base      => $real_jetty_base,
    listen          => $listen,
    logdir          => $real_logdir,
    pidfile         => $real_pidfile,
  }

  Jetty::Version::Install[$name] ->
  Jetty::Version::Config[$name]
}
