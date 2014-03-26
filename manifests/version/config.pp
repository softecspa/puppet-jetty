define jetty::version::config (
  $version,
  $service_startup,
  $jetty_args,
  $java_options,
  $user,
  $jetty_home,
  $jetty_base,
  $listen,
  $logdir,
  $pidfile,
) {

  file{"/etc/init.d/jetty-${version}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => "puppet:///modules/jetty/etc/jetty-${version}",
  }

  file{'/var/log/jetty':
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0775'
  }

  file {$logdir:
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0775',
    require => File['/var/log/jetty']
  }

  file {"/etc/default/jetty-${version}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Concat_build["default-jetty-${version}"]
  }

  concat_build {"default-jetty-${version}":
    order   => ['*.tmp'],
    target  => "/etc/default/jetty-${version}"
  }

  concat_fragment {"default-jetty-${version}+001.tmp":
    content => template("jetty/etc/default-jetty-${version}.erb")
  }

  file {"${jetty_home}/lib/ext/":
    ensure  => present,
    recurse => 'remote',
    mode    => '0775',
    owner   => $user,
    group   => $user,
    source  => 'puppet:///modules/jetty/lib/ext'
  }

}
