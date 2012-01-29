package Text::APL::Base;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = bless {@_}, $class;

    $self->BUILD;

    return $self;
}

sub BUILD {}

1;
