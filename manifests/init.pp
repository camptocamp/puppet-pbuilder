# @summary Provide a pbuilder resource.
#
# @param ensure
#   Whether the pbuilder should be present
# @param release
#   The Debian/Ubuntu release to be used (Buster, Bionic, etc)
# @param arch
#   The architecture of the pbuilder (i386, amd64, etc.)
# @param methodurl
#   The URL used to grab the packages from
#   (e.g. http://deb.debian.org/debian)
# @param debbuildopts
#   The options to send to debuild (see `man dpkg-buildpackage`)
# @param bindmounts
#   A list of space-separated directories to bind-mount in the chroot
# @param bindir
#   Where to put the pbuilder script
# @param chrootdir
#   Where to put the basetgz tarball
# @param cachedir
#   Where to create the aptcache, build and result directories
# @param confdir
#   Where to store the configuration for the script
# @param rctemplate
#   The pbuilderrc ERB template to use
#
# @example Set a pbuilder using the release and architecture of the host
#   pbuilder { 'focal':
#     methodurl => 'http://archive.ubuntu.com/ubuntu',
#   }
#
# @example Destroy an old existing pbuilder
#   pbuilder { 'jessie':
#     ensure => absent,
#   }
#
# @example Set an am64 pbuilder for the etch release, including sources in the .changes
#   pbuilder { 'buster-amd64':
#     release      => buster,
#     methodurl    => 'http://deb.debian.org/debian',
#     debbuildopts => "-sa",
#   }
define pbuilder (
  Enum['present', 'absent'] $ensure = 'present',
  String[1] $release = $lsbdistcodename,
  String[1] $arch = $architecture,
  Optional[String[1]] $methodurl = undef,
  String $debbuildopts = '-b',
  Optional[String[1]] $bindmounts   = undef,
  Stdlib::Absolutepath $bindir       = '/usr/local/bin',
  Stdlib::Absolutepath $chrootdir    = '/var/chroot/pbuilder',
  Stdlib::Absolutepath $confdir      = '/etc/pbuilder',
  Stdlib::Absolutepath $cachedir     = '/var/cache/pbuilder',
  String[1] $rctemplate   = 'pbuilder/pbuilderrc.erb',
) {
  # Include commons (package and group)
  include 'pbuilder::common'

  $script     = "${bindir}/pbuilder-${name}"

  # directories
  $pbuilder_confdir     = "${confdir}/${name}"
  $pbuilder_cachedir    = "${cachedir}/${name}"
  $builddir             = "${pbuilder_cachedir}/build"
  $resultdir            = "${pbuilder_cachedir}/result"
  $aptcachedir          = "${pbuilder_cachedir}/aptcache"

  # conf
  $pbuilderrc  = "${pbuilder_confdir}/pbuilderrc"
  $aptconfdir  = "${pbuilder_confdir}/apt.config"
  $hookdir     = "${pbuilder_confdir}/hooks"

  # base
  $basetgz     = "${chrootdir}/base_${name}.tgz"

  case $ensure {
    'present': {
      # LEGACY: ensure all the dirs exist recursively
      #         the file type can't do that yet
      exec {
        "confdir-${name}":
          command => "/bin/mkdir -p ${pbuilder_confdir}",
          creates => $pbuilder_confdir;
        "bindir-${name}":
          command => "/bin/mkdir -p ${bindir}",
          creates => $bindir;
        "chrootdir-${name}":
          command => "/bin/mkdir -p ${chrootdir}",
          creates => $chrootdir;
        "cachedir-${name}":
          command => "/bin/mkdir -p ${pbuilder_cachedir}",
          creates => $pbuilder_cachedir;
      }

      file {
        $script:
          ensure  => file,
          mode    => '0755',
          content => template('pbuilder/script.erb'),
          require => Exec["bindir-${name}"];
        [$builddir, $resultdir, $aptcachedir]:
          ensure  => directory,
          require => Exec["cachedir-${name}"];
        $aptconfdir:
          ensure  => directory,
          recurse => true,
          require => Exec["confdir-${name}"];
        $hookdir:
          ensure  => directory,
          recurse => true,
          # TODO hookdir source
          #              source  => "puppet://${server}/pbuilder/hookdir/${site}",
          require => Exec["confdir-${name}"];
        $pbuilderrc:
          ensure  => file,
          content => template($rctemplate),
          require => Exec["confdir-${name}"];
      }

      # create the pbuilder if it was not created yet
      exec { "create_pbuilder_${name}":
        command => "${script} create",
        creates => $basetgz,
        require => [Package['pbuilder'],
          File[$script], File[$aptconfdir],
          File[$pbuilderrc], File[$builddir], File[$aptcachedir],
          Exec["chrootdir-${name}"]
        ],
      }

      # update the pbuilder if the config changes but only if $basetgz exists
      exec { "update_pbuilder_${name}":
        command     => "${script} update --override-config",
        onlyif      => "/usr/bin/test -f ${basetgz}",
        subscribe   => [File[$aptconfdir], File[$pbuilderrc]],
        refreshonly => true,
        require     => [Package['pbuilder'],
          File[$script], File[$aptconfdir],
          File[$pbuilderrc], File[$builddir], File[$aptcachedir],
          Exec["chrootdir-${name}"]
        ],
      }
    }

    'absent': {
      # clean pbuilder to be sure no proc/dev is mounted in $builddir
      exec { "clean_pbuilder_${name}":
        command => "${script} clean",
        onlyif  => "/usr/bin/test -f ${script}",
        require => Package['pbuilder'],
      }

      file {
        # remove single files
        [$script, $pbuilderrc, $basetgz]:
          ensure  => absent,
          require => Exec["clean_pbuilder_${name}"];
        # recursively remove internal directories
        [$aptconfdir, $builddir, $resultdir, $aptcachedir]:
          ensure  => absent,
          require => Exec["clean_pbuilder_${name}"],
          recurse => true;
        # recursively remove containing directories
        [$pbuilder_confdir, $pbuilder_cachedir]:
          ensure  => absent,
          require => [Exec["clean_pbuilder_${name}"],
            File[$script], File[$pbuilderrc],
            File[$aptconfdir],
            File[$builddir], File[$resultdir], File[$aptcachedir]
          ];
      }
    }

    default: {
      fail "\$value must be one of 'present' or 'absent'."
    }
  }
}
