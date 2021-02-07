# @summary Manage preferences for a pbuilder setup
# @api private
define pbuilder::apt::preferences (
  $pbuilder_name,
  $priority,
  $ensure        = 'present',
  $pbuilder_type = 'pbuilder',
  $package       = undef,
  $version       = undef,
) {
  $packages = $package ? {
    undef   => $name,
    default => $package,
  }

  $fname = regsubst($name, '\.', '-', 'G')

  # apt support preferences.d since version >= 0.7.22
  # but we can't simply test for the version used in the pbuilder
  # so we just concatenate
  $pin_release = undef
  $origin = undef
  $explanation = "${caller_module_name}: ${name}"
  concat::fragment { $fname:
    ensure  => $ensure,
    target  => "/etc/pbuilder/${pbuilder_name}/apt/preferences",
    content => template('apt/pin.pref.erb'),
    notify  => Exec["update ${pbuilder_type} ${pbuilder_name}"],
  }
}
