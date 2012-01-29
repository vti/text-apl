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
