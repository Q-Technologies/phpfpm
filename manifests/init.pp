class phpfpm (
  # Class parameters are populated from module hiera data
){

  $phpfpm_conf_dir = "/etc/php5/fpm/"
  $phpfpm_pool_dir = "/etc/php5/fpm/pool.d"

  file { "${phpfpm_conf_dir}":
    ensure  => directory,
  }

  file { "${phpfpm_pool_dir}":
    ensure  => directory,
    recurse => true,
    purge   => true,
  }
  file { "${phpfpm_conf_dir}/php-fpm.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp('phpfpm/phpfpm_conf.epp', { phpfpm_pool_dir => $phpfpm_pool_dir } ),
    notify  => Service['php-fpm'],
  }
  service { "php-fpm":
    ensure  => true,
    enable  => true,
  }

  package { 'php5-fpm':
    ensure  => installed,
  }
  
}
