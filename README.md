# OpenStack PostgreSQL Backup Module

This module installs and configures PostgreSQL Backup

## Description

The pgsql_backup::backup resource creates a regular backup of
postgresql database, rotated daily into /var/backups/pgsql_backups
directory.

## Usage

### pgsql::backup

    pgsql_backup::backup { 'database_name':
      database_host => 'localhost',
      database_user => 'database_password',
      database_password => 'database_password',
    }