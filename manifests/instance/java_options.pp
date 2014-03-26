define jetty::instance::java_options (
  $instance_name,
  $option,
) {

  if !defined(Jetty::Instance[$instance_name]) {
    fail("Jetty::Instance[${instance_name}] must be defined")
  }

  concat_fragment {"default-jetty-${instance_name}+002_${name}.tmp":
    content => template("jetty/etc/java_options.erb")
  }

}
