define jetty::instance::install (
  $version,
  $instance_name,
  $jetty_base,
  $user,
) {

  File {
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0775'
  }

  file {$jetty_base:}

  file {"${jetty_base}/start.d":
    require => File[$jetty_base]
  }

  file {"${jetty_base}/webapps":
    require => File[$jetty_base]
  }

  file {"${jetty_base}/logs":
    require => File[$jetty_base]
  }

  file {"${jetty_base}/lib":
    require => File[$jetty_base]
  }

  file {"${jetty_base}/lib/ext":
    require => File["${jetty_base}/lib"]
  }

  file {"${jetty_base}/resources":
    require => File[$jetty_base]
  }

  file {"/etc/init.d/jetty-${instance_name}":
    ensure  => link,
    target  => "/etc/init.d/jetty-${version}"
  }

}
