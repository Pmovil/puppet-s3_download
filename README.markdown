##Description

This module contains a custom type that mantain an true file on filesystem synced with a AWS S3 file

##Setup

###Requirements

* Puppet 3.0 or greater
* Ruby 2.0 or greater
* Amazon AWS Ruby SDK (available as a gem)

###Installing

1. Install the Amazon AWS Ruby SDK gem.

      `gem install aws-sdk-core`

  * Please, verify witch ruby/gem is in by puppet on your environment:

  Once the gems are installed, restart Puppet Server.
  
2. Install the module with:

~~~
puppet module install pmovil-s3synced_file
~~~

##Usage

~~~
s3synced_file{'/path/to/your/file.ext':
        access_key_id => 'xxxx',
        secret_access_key => 'xxxx',
        region => 'us-west-1',
        bucket => 'your-bucket',
        key => 'your/path/in/s3/object.ext',
        ensure => present,
        mode => 0644, #optional
        owner => 'user', #optional
        group => 'group' #optional
}
~~~
