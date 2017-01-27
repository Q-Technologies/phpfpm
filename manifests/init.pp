class phpfpm (
  # Class parameters are populated from module hiera data - but can be overridden by global hiera
  String   $service,
  String   $package,
  String   $conf_dir,
  String   $socket_dir,
  String   $pid_dir,
  String   $log_dir,
  Data     $www_pool_ini,

  # These class parameters are populated from global hiera data
  String   $pool_dir     = "${conf_dir}/pool.d",
  String   $conf_file    = "${conf_dir}/php-fpm.conf",
  String   $php_ini_file = "${conf_dir}/php.ini",

){
  # Merge the hash from all hiera data
  $php_ini  = hiera_hash( 'phpfpm::php_ini', {} )
  $pool_ini = hiera_hash( 'phpfpm::pool_ini', {} )

  # Make sure the parent directory exist - plus manage all the pools in a directory
  file { $conf_dir:
    ensure  => directory,
  } ->
  file { $pool_dir:
    ensure  => directory,
    recurse => true,
    purge   => true,
  }

  # PHP FPM main config file
  file { $conf_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    notify  => Service['php-fpm'],
    require => File[$conf_dir],
    content => epp('phpfpm/phpfpm_conf.epp', { 
      phpfpm_pool_dir => $pool_dir,
      pool_ini        => $www_pool_ini,
      log_dir         => $log_dir,
      socket_dir      => $socket_dir,
      pid_dir         => $pid_dir,
    } ),
  }

  # PHP FPM php.ini config file - only write if we have data to give it
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
