class other {
  $packages = [
    "curl",
    "vim",
    "htop"
  ]

  exec { "apt-get update":
    command => "/usr/bin/apt-get update"
  }

  package { $packages:
    ensure => present,
    require => Exec["apt-get update"]
  }
}

class apache {
  package { "apache2":
    ensure => present,
  }

  file { "/etc/apache2/mods-enabled/rewrite.load":
    ensure => link,
    target => "/etc/apache2/mods-available/rewrite.load",
    require => Package["apache2"]
  }

  file { "/etc/apache2/mods-enabled/headers.load":
    ensure => link,
    target => "/etc/apache2/mods-available/headers.load",
    require => Package["apache2"]
  }

  file { "/etc/apache2/sites-available/vagrant_webroot":
    ensure => present,
    source => "/vagrant/manifests/vagrant_webroot",
    require => Package["apache2"]
  }

  file { "/etc/apache2/sites-enabled/000-default":
    ensure => link,
    target => "/etc/apache2/sites-available/vagrant_webroot",
    require => File["/etc/apache2/sites-available/vagrant_webroot"]
  }

  file { "/etc/apache2/envvars":
    ensure => present,
    source => "/vagrant/manifests/envvars",
    owner => "root",
    group => "root",
    require => Package["apache2"]
  }

  service { "apache2":
    ensure => running,
    require => Package["apache2"],
    subscribe => [
      File["/etc/apache2/mods-enabled/rewrite.load"],
      File["/etc/apache2/mods-enabled/headers.load"],
      File["/etc/apache2/sites-available/vagrant_webroot"]
    ]
  }
}

class php {
  $packages = [
    "php5",
    "php5-cli",
    "php5-mysql",
    "php-pear",
    "php5-dev",
    "php-apc",
    "php5-mcrypt",
    "php5-gd",
    "php5-curl",
    "php5-xdebug",
    "libapache2-mod-php5"
  ]

  package { $packages:
    ensure => present,
    require => Exec["apt-get update"]
  }
}

class mysql {
  package { "mysql-server":
    ensure => present,
    require => Exec["apt-get update"]
  }

  service { "mysql":
    ensure => running,
    require => Package["mysql-server"]
  }

  exec { "set-mysql-password":
    unless  => "mysql -uroot -proot",
    path    => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password root",
    require => Service["mysql"],
  }
}

class groups {
  group { "puppet":
    ensure => present,
  }
}

include other
include apache
include php
include mysql
include groups
