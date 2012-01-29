package Text::APL::Context;

use strict;
use warnings;

use base 'Text::APL::Base';

sub BUILD {
    my $self = shift;

    $self->{vars}    ||= {};
    $self->{helpers} ||= {};
}

sub path    { $_[0]->{path} }
sub vars    { $_[0]->{vars} }
sub helpers { $_[0]->{helpers} }

1;
