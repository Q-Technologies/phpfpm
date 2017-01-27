# Defined type to create an FPM pool
define phpfpm::pool (
  # Class parameters are populated from module hiera data
  String $domain     = '',
  String $socket_dir = '',
  Data   $pool_ini   = '',
){

  include phpfpm
  include stdlib

  if $name == '' {
    # Puppet won't let this happen anyway, but let's be explicit
    fail( 'Name cannot be blank' )
  }
  if $domain == '' {
    $domain_name = $name
  } else {
    $domain_name = $domain
  }

  $label = regsubst( $domain_name, '\.', '_', 'G' )
  file { "${phpfpm::pool_dir}/${domain_name}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    notify  => Service['php-fpm'],
    require => File[$phpfpm::pool_dir],
    content => epp('phpfpm/phpfpm_pool_conf.epp', {
      domain     => $domain_name,
      name       => $label,
      socket_dir => $socket_dir,
      pool_ini   => deep_merge( $phpfpm::pool_ini, $pool_ini )
    } ),
  }
}
