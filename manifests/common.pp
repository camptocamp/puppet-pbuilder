# @summary Manage generic resources for pbuilder
# @api private
#
# This class is imported from the pbuilder type. It manages generic resources
# for pbuilder, being the pbuilder package and UNIX group.
class pbuilder::common {
  # Call this class from within the pbuilder definition

  package { 'pbuilder':
    ensure => installed,
  }

  group { 'pbuilder':
    ensure => present,
    system => true,
  }
}
