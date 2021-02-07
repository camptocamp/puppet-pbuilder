Pbuilder Puppet module
======================

[![Puppet Forge Version](http://img.shields.io/puppetforge/v/puppet/pbuilder.svg)](https://forge.puppetlabs.com/puppet/pbuilder)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/puppet/pbuilder.svg)](https://forge.puppetlabs.com/puppet/pbuilder)
![CI](https://github.com/voxpupuli/puppet-pbuilder/workflows/CI/badge.svg)
[![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/puppet/pbuilder.svg)](https://forge.puppetlabs.com/puppet/pbuilder)
[![By Camptocamp](https://img.shields.io/badge/by-camptocamp-fb7047.svg)](http://www.camptocamp.com)


# Overview

Pbuilder is a building utility for Debian systems based on sbuild.

## pbuilder

This module assumes the following directories:

Configuration:
 - ${confdir}/$name : root for the pbuilder conf
 - ${confdir}/$name/pbuilderrc : configuration file for the pbuilder
 - ${confdir}/$name/apt.config : apt config file (including sources.list) for the pbuilder
 - ${confdir}/$name/hooks : hooks for the pbuilder

Cache:
 - ${cachedir}/$name : root for the pbuilder cache
 - ${cachedir}/$name/aptcache : aptcache for the pbuilder
 - ${cachedir}/$name/build : build directory for the pbuilder
 - ${cachedir}/$name/result : result packages for the pbuilder

Chroot:
 - ${chrootdir}/base_$name.tgz : compressed chroot for the pbuilder

### Important note

You have to provide a valid apt.config directory for your pbuilder.
You can use the apt class for that, and notify the private pbuilder_update Exec.

# Licence

Copyright © 2007-2018 Raphaël Pinson <raphink@gmail.com>
See the LICENSE file for the full license.
