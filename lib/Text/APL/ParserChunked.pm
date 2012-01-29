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
__END__

=pod

=head1 NAME

Text::APL::ParserChunk - parser that reads chunks

=head1 DESCRIPTION

Modification of L<Text::APL::Parser> that can parse chunks of texts instead of
parsing a whole document. Correctly processes hanging leftovers that are
resolved in the next chunk. Stops parsing when passed an undefined chunk.

=head1 METHODS

=head2 C<parse_chunk>

Parse a template's chunk.

=head2 C<parse_chunk_final>

Parse a template's final chunk.

=cut
