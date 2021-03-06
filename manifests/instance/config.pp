define jetty::instance::config (
  $version,
  $instance_name,
  $service_startup  = true,
  $listen,
  $user,
  $jetty_home,
  $jetty_base,
  $logdir,
  $pidfile,
  $jetty_args,
  $java_options,
  $port
) {

  file {"/etc/default/jetty-${instance_name}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Concat_build["default-jetty-${instance_name}"],
    notify  => Service["jetty-${instance_name}"]
  }

  file {$logdir:
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0775',
    require => File['/var/log/jetty']
  }

  concat_build {"default-jetty-${instance_name}":
    order   => ['*.tmp'],
    target  => "/etc/default/jetty-${instance_name}"
  }

  concat_fragment {"default-jetty-${instance_name}+001.tmp":
    content => template("jetty/etc/default-jetty-${version}.erb")
  }

  file {"${jetty_base}/start.d/http.ini":
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0644',
    content => template('jetty/http.ini.erb'),
    notify  => Service["jetty-${instance_name}"]
  }

  file {"${jetty_base}/start.ini":
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0644',
    content => template('jetty/start.ini.erb'),
    notify  => Service["jetty-${instance_name}"]
  }

  file {"${jetty_base}/resources/log4j.properties":
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0644',
    content => template('jetty/log4j.properties.erb'),
    notify  => Service["jetty-${instance_name}"]
  }

  if $java_options!= '' {
    jetty::instance::java_options{"options_${instance_name}":
      instance_name => $instance_name,
      option        => $java_options,
    }
  }
}
