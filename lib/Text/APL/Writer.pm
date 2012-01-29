package Text::APL::Writer;

use strict;
use warnings;

use base 'Text::APL::Base';

sub build {
    my $self = shift;
    my ($output) = @_;

    my $writer;

    if (ref $output eq 'SCALAR') {
        ${$output} = '';
        $writer = sub { ${$output} .= $_[0] if defined $_[0] };
    }
    elsif (ref $output eq 'CODE') {
        $writer = $output;
    }
    else {
        die 'Do not know how to write';
    }

    return $writer;
}

1;
