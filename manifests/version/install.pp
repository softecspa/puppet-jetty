define jetty::version::install (
  $version,
  $package_s3_bucket    = '',
  $package_download_url = '',
  $root,
  $user,
  $user_uid             = undef,
  $user_gid             = undef,
) {

  require s3cmd

  if ($package_s3_bucket == '') and ($package_download_url == '') {
    fail('please specify package_s3_bucket or download_url')
  }

  if ($package_s3_bucket != '') and ($package_download_url != '') {
    fail('please specify only package_s3_bucket or package_download_url')
  }

  # PACKAGE DOWNLOAD #######################################
  if $package_s3_bucket != '' {
    s3cmd::get{"jetty-${version}.tar.gz":
      bucket_name      => $package_s3_bucket,
      target_path      => $root,
    }
  }

  if $package_download_url != '' {
    exec {"download jetty-${version}":
      command => "/usr/bin/wget \"${package_download_url}\" -O ${root}/jetty-${version}.tar.gz",
      creates => "${root}/jetty-${version}.tar.gz"
    }
  }
  #########################################################

  user {$user :
    ensure  => present,
    comment => 'jetty user',
    gid     => $user_gid,
    uid     => $user_uid,
    shell   => '/bin/false'
  }

  file {"${root}/jetty-${version}":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0775',
    require => User[$user]
  }

  exec {"extract jetty-${version}":
    command => "/bin/tar -zxf ${root}/jetty-${version}.tar.gz -C ${root}/jetty-${version} --strip-components 1; /bin/chown ${user}:${user} ${root}/jetty-${version} -R",
    creates => "${root}/jetty-${version}/start.jar",
    require => File["${root}/jetty-${version}"]
  }
}
