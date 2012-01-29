package Text::APL::Decorator::Base;

use strict;
use warnings;

sub new {
    my $class  = shift;
    my $object = shift;

    my $self = bless {object => $object, @_}, $class;

    $self->BUILD;

    return $self;
}

sub BUILD { }

1;
