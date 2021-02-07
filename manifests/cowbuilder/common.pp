# @summary Basic installation of cowbuilder
# @api private
class pbuilder::cowbuilder::common inherits pbuilder::common {
  package { 'cowbuilder':
    ensure => installed,
  }

  file { '/etc/pbuilderrc':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "# file managed by puppet
MIRRORSITE=\"http://http.debian.net/debian\"

DEBBUILDOPTS=\"-sa\"
unset DEBOOTSTRAPOPTS

if [ -z \"\${NAME}\" ]; then
  echo \"W: Could not find pbuilder name\"
else
  if [ -d \"/etc/pbuilder/\${NAME}/apt\" ]; then
    APTCONFDIR=\"/etc/pbuilder/\${NAME}/apt\"
  fi

  if [ -f \"/etc/pbuilder/\${NAME}/pbuilderrc\" ]; then
    echo \"I: Including /etc/pbuilder/\${NAME}/pbuilderrc\" >&2
    . \"/etc/pbuilder/\${NAME}/pbuilderrc\"
  else
    echo \"I: Could not find /etc/pbuilder/\${NAME}/pbuilderrc\" >&2
  fi
fi
",
  }
}
