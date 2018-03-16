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

package Foswiki::Plugins::SectionListPlugin::Core;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Attrs ();
use Foswiki::Plugins ();

use constant TRACE => 0; # toggle me

sub new {
  my $class = shift;
  my $session = shift;

  #_writeDebug("new SectionListPlugin::Core");

  my $this = bless({
    session => $session,
    @_
  }, $class);


  return $this;
}

sub handleSECTIONLIST {
  my ($this, $params, $topic, $web) = @_;

  my $theTopic = $params->{_DEFAULT} || $params->{topic} || $topic;
  my $theRev = $params->{rev};
  my $theType = $params->{type};

  my $theWeb = $web;
  ($theWeb, $theTopic) = Foswiki::Func::normalizeWebTopicName($theWeb, $theTopic);

  _writeDebug("handleSECTIONLIST($theWeb, $theTopic, ".($theRev//'').")");

  return _inlineError("topic not found") 
    unless Foswiki::Func::topicExists($theWeb, $theTopic);
  return _inlineError("access denied")
    unless Foswiki::Func::checkAccessPermission("VIEW", $this->{session}{user}, undef, $theTopic, $theWeb);


  my ($meta, $text) = Foswiki::Func::readTopic($theWeb, $theTopic, $theRev);

  my @sections = ();
  my %found = ();
  foreach my $bit (split( /(%(?:START|STOP|END)SECTION(?:{.*?})?%)/, $text )) {
    next unless $bit =~ m/^%STARTSECTION(?:{(.*)})?%$/;
    my $attrs = new Foswiki::Attrs($1);
    my $name = $attrs->{name} || $attrs->{_DEFAULT} || '';
    my $type = $attrs->{type} || 'section';
    next if defined $theType && $theType ne $type;
    next if $found{$name};
    $found{$name} = 1;
    push @sections, {
      name => $name,
      type => $type,
    };
  }
  return "" unless @sections;

  my $theHeader = $params->{header} // "";
  my $theFooter = $params->{footer} // "";
  my $theFormat = $params->{format} // '$name';
  my $theSep = $params->{separator} // ", ";
  my $theSort = Foswiki::Func::isTrue($params->{sort}, 0);
  my $theReverse = Foswiki::Func::isTrue($params->{reverse}, 0);
  my $theInclude = $params->{include};
  my $theExclude = $params->{exclude};

  @sections = sort {$a->{name} cmp $b->{name}} @sections if $theSort;
  @sections = reverse @sections if $theReverse;

  my @result = ();

  foreach my $section (@sections) {
    next if defined $theInclude && $section->{name} !~ /$theInclude/;
    next if defined $theExclude && $section->{name} =~ /$theExclude/;
    my $line = $theFormat;
    $line =~ s/\$name/$section->{name}/g;
    $line =~ s/\$type/$section->{type}/g;
    push @result, $line if $line ne "";
  }

  return Foswiki::Func::decodeFormatTokens($theHeader.join($theSep, @result).$theFooter);
}

sub _inlineError {
  my $msg = shift;

  return "<span class='foswikiAlert'>$msg</span>";
}

sub _writeDebug {
  print STDERR '- SectionListPlugin - '.$_[0]."\n" if TRACE;
}

1;
