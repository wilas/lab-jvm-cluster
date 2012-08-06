# Class: postgresql
#
# This module manages postgresql9 on Scientific Linux 6.X
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]

#TODO: auto backup, refresh_db(drop+restore) (give dir with backup and restore last or filename), pg_hba augeas

class postgresql ( $version="9.1", $listen="localhost", $port="5432" ) {

	#Checking operating system
	case $operatingsystem {
		Scientific: {
			if $operatingsystemrelease >= "6.0" {
				class { "postgresql::sl_install":
                    version => $version,
                    listen  => $listen,
                    port    => $port,
                }
			}	
		}
		default: { notice "Unsupported operatingsystem ${operatingsystem}" }
	}

}
