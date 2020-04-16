# Class to manage PHP-FPM
class phpfpm (
  # Class parameters are populated from module hiera data - but can be overridden by global hiera
  String       $service,
  String       $package,
  String       $conf_dir,
  String       $pid_dir,
  Data         $www_pool_ini,
  Boolean  $install_package,
  Boolean  $start_service,

  # These class parameters are populated from global hiera data
  String       $pool_dir     = "${conf_dir}/php-fpm.d",
  String       $conf_file    = "${conf_dir}/php-fpm.conf",
  String       $php_ini_file = "${conf_dir}/php.ini",
  String       $socket_dir   = $nginx::socket_dir,
  String       $log_dir      = $nginx::log_dir,
  Collection   $ensure_dirs  = [],

){
  # Merge the hash from all hiera data
  $php_ini  = hiera_hash( 'phpfpm::php_ini', {} )
  $pool_ini = hiera_hash( 'phpfpm::pool_ini', {} )

  # Make sure the parent directory exist - plus manage all the pools in a directory
  file { $conf_dir:
    ensure  => directory,
  }
  -> file { $pool_dir:
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

  if $start_service {
    service { $service:
      ensure => true,
      enable => true,
    }
  }

  if $install_package {
    package { $package:
      ensure  => installed,
    }
  }

  # Ensure requested directories exist
  $dir_defaults = { ensure => directory, mode => '0750' }
  unless empty( $ensure_dirs ) {
    create_resources( file, $ensure_dirs, $dir_defaults )
  }

}
