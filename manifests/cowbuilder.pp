define pbuilder::cowbuilder (
  $ensure='present',
  $release=$facts['os']['distro']['codename'],
  $arch=$facts['os']['architecture'],
  $cachedir='/var/cache/pbuilder',
  $methodurl=undef,
  $debbuildopts='-b',
  $bindmounts=undef,
  $confdir='/etc/pbuilder',
  $rctemplate='pbuilder/pbuilderrc.erb',
) {
  include pbuilder::cowbuilder::common

  $cowbuilder = '/usr/sbin/cowbuilder'

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
  $basepath = "${cachedir}/base-${name}.cow"

  concat { "${aptconfdir}/preferences":
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['pbuilder'],
  }

  case $ensure {
    'present': {
      file {
        $pbuilder_confdir:
          ensure  => directory,
          require => Package['pbuilder'];

        $pbuilder_cachedir:
          ensure  => directory,
          require => Package['pbuilder'];

        [$builddir, $resultdir, $aptcachedir]:
          ensure  => directory;

        $aptconfdir:
          ensure  => directory;

        "${aptconfdir}/sources.list.d":
          ensure  => directory,
          recurse => true,
          purge   => true;

        $hookdir:
          ensure  => directory,
          recurse => true;

        $pbuilderrc:
          ensure  => file,
          content => template($rctemplate);
      }

      -> exec {
        "create cowbuilder ${name}":
          command     => "${cowbuilder} --create --basepath ${basepath} --dist ${release} --architecture ${arch}",
          environment => ["NAME=${name}"], # used in /etc/pbuilderrc
          require     => File['/etc/pbuilderrc'],
          timeout     => 0,
          creates     => $basepath;

        "update cowbuilder ${name}":
          command     => "${cowbuilder} --update --configfile ${confdir}/${name}/pbuilderrc --basepath ${basepath} --dist ${release} --architecture ${arch} --override-config",
          environment => ["NAME=${name}"], # used in /etc/pbuilderrc
          timeout     => 0,
          refreshonly => true;
      }
    }

    'absent': {
      file {
        $pbuilder_confdir:
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
