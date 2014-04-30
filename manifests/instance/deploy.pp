define jetty::instance::deploy (
  $context_name   = '',
  $instance_name,
  $war_source,
  $war_path,
  $war_name,
  $jetty_base = '',
  $init_parameters = '',
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

  if ($init_parameters != '') and (!is_hash($init_parameters)) {
    fail('init_parameters must be hash')
  }

  file {$xml_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service["jetty-${instance_name}"]
  }

  concat_build {"xml_deploy_${instance_name}":
    order   => ['*.tmp'],
    target  => $xml_file
  }

  concat_fragment{"xml_deploy_${instance_name}+001.tmp":
    content => template('jetty/deploy.xml.erb')
  }

  concat_fragment{"xml_deploy_${instance_name}+999.tmp":
    content => '</Configure>'
  }

  if $init_parameters != '' {
    create_resources('jetty::instance::deploy::init_parameter',$init_parameters,{'instance_name' => $instance_name})
  }
}
