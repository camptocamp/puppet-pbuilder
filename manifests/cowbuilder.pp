# @summary Manage a cowbuilder environment
#
# @param ensure
#   Whether the pbuilder should be present
# @param dist
#   The Debian/Ubuntu release to be used (Buster, Bionic, etc)
# @param arch
#   The architecture of the pbuilder (i386, amd64, etc.)
# @param cachedir
#   Where to create the aptcache, build and result directories
# @param confdir
#   Where to store the configuration for the script
# @param pbuilderrc
#   The pbuilderrc content
define pbuilder::cowbuilder (
  Enum['present', 'absent'] $ensure = 'present',
  String[1] $dist = $facts['os']['distro']['codename'],
  String[1] $arch = $facts['os']['architecture'],
  Stdlib::Absolutepath $cachedir = '/var/cache/pbuilder',
  Stdlib::Absolutepath $confdir = '/etc/pbuilder',
  Optional[String[1]] $pbuilderrc = undef,
) {
  include pbuilder::cowbuilder::common

  $cowbuilder = '/usr/sbin/cowbuilder'
  $basepath = "${cachedir}/base-${name}.cow"

  concat { "${confdir}/${name}/apt/preferences":
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['pbuilder'],
  }

  case $ensure {
    'present': {
      file {
        "${confdir}/${name}":
          ensure  => directory,
          require => Package['pbuilder'];

        "${confdir}/${name}/apt":
          ensure  => directory,
          require => File["${confdir}/${name}"];

        "${confdir}/${name}/apt/sources.list.d":
          ensure  => directory,
          recurse => true,
          purge   => true,
          require => File["${confdir}/${name}/apt"];

        "${confdir}/${name}/pbuilderrc":
          ensure  => file,
          content => $pbuilderrc,
      }

      -> exec {
        "create cowbuilder ${name}":
          command     => "${cowbuilder} --create --basepath ${basepath} --dist ${dist} --architecture ${arch}",
          environment => ["NAME=${name}"], # used in /etc/pbuilderrc
          require     => File['/etc/pbuilderrc'],
          timeout     => 0,
          creates     => $basepath;

        "update cowbuilder ${name}":
          command     => "${cowbuilder} --update --configfile ${confdir}/${name}/pbuilderrc --basepath ${basepath} --dist ${dist} --architecture ${arch} --override-config",
          environment => ["NAME=${name}"], # used in /etc/pbuilderrc
          timeout     => 0,
          refreshonly => true;
      }
    }

    'absent': {
      file {
        "${confdir}/${name}":
          ensure => absent;

        $basepath:
          ensure => absent;
      }
    }

    default: {
      fail("Wrong value for ensure: ${ensure}")
    }
  }
}
