# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (C) 2018 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version. For
# more details read LICENSE in the root of this distribution.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

package Foswiki::Plugins::SectionListPlugin;

use strict;
use warnings;

our $VERSION = '0.01';
our $RELEASE = '16 Mar 2018';
our $NO_PREFS_IN_TOPIC = 1;
our $SHORTDESCRIPTION = 'Access the list of named sections in a topic';
our $core;

use Foswiki::Plugins ();
use Foswiki::Func ();

sub initPlugin {

  Foswiki::Func::registerTagHandler('SECTIONLIST', sub {
    my $session = shift;
    return getCore($session)->handleSECTIONLIST(@_);
  });

  return 1;
}

sub getCore() {
  my $session = shift;

  $session ||= $Foswiki::Plugins::SESSION;

  unless ($core) {
    require Foswiki::Plugins::SectionListPlugin::Core;
    $core = Foswiki::Plugins::SectionListPlugin::Core->new();
  }

  return $core;
}

sub finishPlugin {
  undef $core;
}


1;

