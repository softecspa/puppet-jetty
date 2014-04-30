define jetty::instance::deploy::init_parameter (
  $instance_name,
  $param_value,
  $param_name = '',
) {

  $real_param_name = $param_name?{
    ''      => $name,
    default => $param_name
  }

  concat_fragment {"xml_deploy_${instance_name}+002-${name}.tmp":
    content => template('jetty/deploy_parameter.erb')
  }

}
