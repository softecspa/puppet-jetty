define jetty::instance::service (
  $instance_name,
  $service_startup,
) {

  service {"jetty-${instance_name}":
    ensure  => $service_startup,
    enable  => $service_startup,
  }

}
