# == Define: pgsql_backup::backup
#

define pgsql_backup::backup (
  $database_user,
  $database_password,
  $database_host = 'localhost',
  $database_port = '5432',
  $minute = '0',
  $hour = '0',
  $day = '*',
  $dest_dir = '/var/backups/pgsql_backups',
  $rotation = 'daily',
  $num_backups = '30',
  $pgpass_file = '/root/.pgpass',
) {
  # Wrap in check as there may be mutliple backup defines backing
  # up to the same dir.
  if ! defined(File[$dest_dir]) {
    file { $dest_dir:
      ensure => directory,
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    }
  }

  file { $pgpass_file:
    ensure  => present,
    mode    => '0400',
    owner   => 'root',
    group   => 'root',
    content => template('pgsql_backup/pgpass.erb'),
  }

  if ! defined(Package['postgresql-client']) {
    package { 'postgresql-client':
      ensure => present,
    }
  }

  cron { "${name}-backup":
    ensure  => present,
    command => "/usr/bin/pg_dump -h ${database_host} -U ${database_user} -p ${database_port} ${name} | /bin/gzip > ${dest_dir}/${name}.sql.gz",
    minute  => $minute,
    hour    => $hour,
    weekday => $day,
    require => [
      File[$dest_dir],
      File[$pgpass_file],
      Package['postgresql-client'],
    ],
  }

  include ::logrotate
  logrotate::file { "${name}-rotate":
    log     => "${dest_dir}/${name}.sql.gz",
    options => [
      'nocompress',
      "rotate ${num_backups}",
      $rotation,
    ],
    require => Cron["${name}-backup"],
  }
}

