# Defined type to create an FPM pool
define phpfpm::pool (
  # Class parameters are populated from module hiera data
  String $web_server_name     = '',
  String $socket_dir = '',
  Data   $pool_ini   = '',
){

  include phpfpm
  include stdlib

  if $name == '' {
    # Puppet won't let this happen anyway, but let's be explicit
    fail( 'Name cannot be blank' )
  }
  if $web_server_name == '' {
    $web_server_name_mod = $name
  } else {
    $web_server_name_mod = $web_server_name
  }

  $label = regsubst( $web_server_name_mod, '\.', '_', 'G' )
  file { "${phpfpm::pool_dir}/${web_server_name_mod}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    notify  => Service['php-fpm'],
    require => File[$phpfpm::pool_dir],
    content => epp('phpfpm/phpfpm_pool_conf.epp', {
      web_server_name => $web_server_name_mod,
      name            => $label,
      socket_dir      => $socket_dir,
      pool_ini        => deep_merge( $phpfpm::pool_ini, $pool_ini )
    } ),
  }
}
