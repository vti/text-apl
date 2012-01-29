package Text::APL::Decorator::Preprocessor;

use strict;
use warnings;

use base 'Text::APL::Decorator::Base';

sub render {
    my $self  = shift;
    my $input = shift;

    $input = $self->_preprocess($input);

    return $self->{object}->render($input, @_);
}

sub _preprocess {
    my $self = shift;
    my ($input) = @_;

    return $input;
}

1;
