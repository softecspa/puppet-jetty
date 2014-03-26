define jetty::instance::deploy (
  $context_name   = '',
  $instance_name,
  $war_source,
  $war_path,
  $war_name,
  $jetty_base = '',
) {

  $context = $context_name? {
    ''      => $name,
    default => $context_name,
  }

  validate_absolute_path($war_path)

  if !defined(File["${war_path}/${war_name}"]) {
    file {"${war_path}/${war_name}":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => $war_source,
      notify  => Service["jetty-${instance_name}"]
    }
  }

  $xml_file = $jetty_base? {
    ''      => "/opt/jetty-${instance_name}/webapps/deploy_${war_name}.xml",
    default => "${jetty_base}/webapps/deploy_${war_name}.xml"
  }

  file {$xml_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('jetty/deploy.xml.erb'),
    notify  => Service["jetty-${instance_name}"]
  }
}
