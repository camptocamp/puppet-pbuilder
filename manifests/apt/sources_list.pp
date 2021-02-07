# @summary Manage sources.list for a pbuilder setup
# @api private
define pbuilder::apt::sources_list (
  $pbuilder_name,
  $ensure='present',
  $source=false,
  $content=false,
  $pbuilder_type='pbuilder',
  $filename=undef,
) {
  $file = $filename ? {
    undef   => "/etc/pbuilder/${pbuilder_name}/apt/sources.list.d/${name}.list",
    default => "/etc/pbuilder/${pbuilder_name}/apt/sources.list.d/${filename}.list",
  }

  if $source {
    file { $file:
      ensure => $ensure,
      source => $source,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      notify => Exec["update ${pbuilder_type} ${pbuilder_name}"],
    }
  } else {
    file { $file:
      ensure  => $ensure,
      content => $content,
      notify  => Exec["update ${pbuilder_type} ${pbuilder_name}"],
    }
  }
}
