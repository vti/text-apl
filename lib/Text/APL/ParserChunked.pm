package Text::APL::ParserChunked;

use strict;
use warnings;

use base 'Text::APL::Base';

use Text::APL::Parser;

sub _BUILD {
    my $self = shift;

    $self->{parser} ||= Text::APL::Parser->new;

    return $self;
}

sub parse {
    my $self = shift;

    @_ ? $self->_parse_chunk(@_) : $self->_parse_chunk_final;
}

sub _parse_chunk {
    my $self = shift;
    my ($input) = @_;

    if (my $buffer = delete $self->{buffer}) {
        $input = delete($buffer->{value}) . $input;
    }

    my $tape = $self->{parser}->parse($input);

    if (@$tape && $tape->[-1]->{type} eq 'text') {
        $self->{buffer} = pop @$tape;
    }

    $tape;
}

sub _parse_chunk_final {
    my $self = shift;

    my $tape = [];

    if (my $buffer = delete $self->{buffer}) {
        $tape = $self->{parser}->parse($buffer->{value});
    }

    $tape;
}

1;
__END__

=pod

=head1 NAME

Text::APL::ParserChunk - parser that reads chunks

=head1 DESCRIPTION

Modification of L<Text::APL::Parser> that can parse chunks of texts instead of
parsing a whole document. Correctly processes hanging leftovers that are
resolved in the next chunk. Stops parsing when passed an undefined chunk.

=head1 METHODS

=head2 C<parse>

Parse a template's chunk.

=cut
