# puppet-phpfpm
Puppet module to manage PHP-FPM basic config, php.ini and pools.

It has been designed to fit in nicely with our Nginx module: [qtechnologies/nginx](https://github.com/Q-Technologies/puppet-nginx.git).  If this Nginx module is installed, this module grabs some parameters from it - things are less likely to break if there's only one source of data - especially for the shared sockets locations.

Currently only tested on SUSE, but other platforms should work with the right hiera data.

## Instructions
### Global Settings
You can also overide internal defaults in hiera, if required, e.g.:
```yaml
phpfpm::conf_dir: /etc/php5/fpm
phpfpm::service: php-fpm
phpfpm::package: php5-fpm
phpfpm::socket_dir: /var/sockets
phpfpm::pid_dir: /var/run
phpfpm::log_dir: /var/log/nginx
phpfpm::www_pool_ini:
  user: nobody
  group: nobody
  listen.mode: '0666'
  pm: dynamic
  pm.max_children: 5
  pm.start_servers: 2
  pm.min_spare_servers: 1
  pm.max_spare_servers: 3
  'env[PATH]': /usr/bin:/bin
  'env[TMP]': /tmp
  'env[TMPDIR]': /tmp
  'env[TEMP]': /tmp
phpfpm::pool_ini:
  user: wwwrun
  group: www
  listen.backlog: -1
  listen.mode: '0666'
  pm: dynamic
  pm.max_children: 9
  pm.start_servers: 3
  pm.min_spare_servers: 2
  pm.max_spare_servers: 4
  pm.max_requests: 10000
  request_slowlog_timeout: 5s
  slowlog: /var/log/$pool.log.slow
  request_terminate_timeout: 300s
  rlimit_files: 131072
  rlimit_core: unlimited
  catch_workers_output: 'yes'
  'env[TMP]': /tmp
  'env[TMPDIR]': /tmp
  'env[TEMP]': /tmp
```
The global settings will be written whenever the class is included - it is automatically included whenever the pool resource is used.

### Creating a Pool
Simply use the `phpfpm::pool` resource, like this:
```puppet
      phpfpm::pool { 'www.example.com': }
```
This will create a pool for the specific web server name based on a template.

It also takes the following paramters:
* `web_server_name` - web server name to use, otherwise use the resource name
* `socket_dir` - the directory to set up the UNIX sockets in - must match NGINX (does by default)
* `pool_ini` - can overwrite the global pool ini data.  It is merged, so you only need to specify differences.

#### Pool Configuration
The pool ini data can be specified through hiera by defining `phpfpm::pool_ini` - it will be merged across hiera.

### Configuring the global php.ini for FPM
If you create hiera data for the `php.ini` it will manage that as well.  E.g.:
```yaml
################################################################################
#
# PHP FPM Configuration
#
################################################################################
phpfpm::php_ini:
  post_max_size: 30M
  upload_max_filesize: 20M
  date.timezone: '"Australia/Melbourne"'
  variable_orders: EGPCS
  session.save_path: '"/var/lib/web-sessions"'
  memory_limit: 256M
```
**NB:** for the strings to be quoted in the `php.ini` they need to be quoted inside single quotes in the hiera data.


## Issues
This module is using hiera data that is embedded in the module rather than using a params class.  This may not play nicely with other modules using the same technique unless you are using hiera 3.0.6 and above (PE 2015.3.2+).

It has only been tested on SUSE systems, using SUSE paths - patches for other platforms are welcome - we just need to create internal hiera data for the OS family.
