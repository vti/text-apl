package Text::APL::ParserChunked;

use strict;
use warnings;

use base 'Text::APL::Base';

use Text::APL::Parser;

sub BUILD {
    my $self = shift;

    $self->{parser} ||= Text::APL::Parser->new;

    return $self;
}

sub parse_chunk {
    my $self = shift;
    my ($input) = @_;

    my $tape = $self->{parser}->parse($input);

    if (@$tape && $tape->[-1]->{type} eq 'text') {
        $self->{buffer} = pop @$tape;
    }

    $tape;
}

sub parse_chunk_final {
    my $self = shift;
    my ($input) = @_;

    $input = '' unless defined $input;

    if (my $buffer = delete $self->{buffer}) {
        $input = $buffer->{value} . $input;
    }

    $self->{parser}->parse($input);
}

1;
