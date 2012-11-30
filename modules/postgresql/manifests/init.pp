# TODO: 
# - auto backup
# - refresh_db (dropdb + restoredb) (restore from last filename from given backup_dir or restore from given filename)
# - manage pg_hba using augeas
#
# Remember to set up firewall rules in db_node configuration or in other specific module
#
class postgresql ( $version="9.1", $listen="localhost", $port="5432" ) {

	# Checking operating system
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
