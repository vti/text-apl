package Text::APL::ParserFactory;

use strict;
use warnings;

use Text::APL::ParserChunked;

use base 'Text::APL::Base';

sub build {
    my $class = shift;

    return Text::APL::ParserChunked->new(@_);
}

1;
__END__

=pod

=head1 NAME

Text::APL::ParserFactory - parser builder

=head1 DESCRIPTION

Builds a parser used in L<Text::APL>. By default returns
L<Text::APL::ParserChunked> instance.

=head1 METHODS

=head2 C<build>

Build parser.

=cut
