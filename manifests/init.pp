class phpfpm (
  # These class parameters are populated from module hiera data
  $service,
  $package,
  $conf_dir,

  # These class parameters are populated from global hiera data
  Data $php_ini = {},
  String $pool_dir = "${conf_dir}/pool.d",
  String $conf_file = "${conf_dir}/php-fpm.conf",
  String $php_ini_file = "${conf_dir}/php.ini",

){

  file { $conf_dir:
    ensure  => directory,
  } ->
  file { $pool_dir:
    ensure  => directory,
    recurse => true,
    purge   => true,
  } ->
  file { $conf_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp('phpfpm/phpfpm_conf.epp', { phpfpm_pool_dir => $pool_dir } ),
    notify  => Service['php-fpm'],
  }

  unless empty($php_ini) {
    file { $php_ini_file:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => epp('phpfpm/php_ini.epp', { php_ini => $php_ini } ),
      notify  => Service['php-fpm'],
      require => File[$conf_dir],
    }
  }

  service { $service:
    ensure  => true,
    enable  => true,
  }

  package { $package:
    ensure  => installed,
  }
  
}
