# ===========================================================================
# Copyright 2006, Everitz Consulting (mt@everitz.com)
# ===========================================================================
package MT::Plugin::ParseTag;

use base qw(MT::Plugin);
use strict;

use MT;

my $ParseTag;
my $about = {
  name => 'MT-ParseTag',
  description => 'Processes the contents of a template tag.',
  author_name => 'Everitz Consulting',
  author_link => 'http://www.everitz.com/',
  version => '0.0.6'
};
$ParseTag = MT::Plugin::ParseTag->new($about);
MT->add_plugin($ParseTag);

use MT::Template::Context;
MT::Template::Context->add_container_tag(ParseTag => \&ParseTag);
MT::Template::Context->add_tag(ParseTagContent => \&ReturnValue);
MT::Template::Context->add_tag(ParseTagCounter => \&ReturnValue);

sub ParseTag {
  my ($ctx, $args) = @_;
  defined (my $entry = $ctx->stash('entry'))
    or return $ctx->error("<ParseTag> must be used in an entry.");
  my $more = $entry->text_more;
  return '' unless $more;
  my @more = split /\r?\n/, $more;
  my $builder = $ctx->stash('builder');
  my $tokens = $ctx->stash('tokens');
  my $res = '';
  my $x = 1;
  for my $line (@more) {
    local $ctx->{__stash}{parsetagcontent} = $line;
    local $ctx->{__stash}{parsetagcounter} = $x;
    my $out = $builder->build($ctx, $tokens);
    return $ctx->error($builder->errstr) unless defined $out;
    $res .= $out;
    $x++;
  }
  $res;
}

sub ReturnValue {
  my ($ctx, $args) = @_;
  my $val = $ctx->stash(lc($ctx->stash('tag')));
  $val;
}

1;