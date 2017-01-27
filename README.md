# puppet-phpfpm
Puppet module to manage PHP-FPM basic config and pools.

## Instructions
Simply use the defined 'phpfpm::pool' resource, like this:
```
      phpfpm::pool { 'www.example.com': }
```
This will create a pool for the specific domain based on a template.  It will also include the greater parts of this module which will define the main PHP-FPM config file according to a template.  

## Issues
This module is using hiera data that is embedded in the module rather than using a params class.  This may not play nicely with other modules using the same technique unless you are using hiera 3.0.6 and above (PE 2015.3.2+).

At the moment the templates are quite fixed, but will be parametised in time.  

Also, it has only been tested on SUSE systems, using SUSE paths - other platforms will be supported eventually.
