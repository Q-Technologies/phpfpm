define phpfpm::pool (
  # Class parameters are populated from module hiera data
  String $domain = '',
){

  include phpfpm
  include stdlib

  if $name == '' {
    fail( "Name cannot be blank" )
  }
  if $domain == '' {
    $domain_name = $name
  } else {
    $domain_name = $domain
  }

  $label = regsubst( $domain_name, '\.', '_', 'G' )
  file { "${phpfpm::phpfpm_pool_dir}/${domain_name}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp('phpfpm/phpfpm_pool_conf.epp', { domain => $domain_name, name => $label} ),
    notify  => Service['php-fpm'],
  }
}
