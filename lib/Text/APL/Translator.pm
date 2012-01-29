package Text::APL::Translator;

use strict;
use warnings;

use base 'Text::APL::Base';

sub translate {
    my $self = shift;
    my ($tape) = @_;

    my $code = '';

    foreach my $token (@$tape) {
        if ($token->{type} eq 'expr') {
            my $value = $token->{value};
            if (exists $token->{as_is} && $token->{as_is}) {
                $code .= '__print(do {' . $value . '});';
            }
            else {
                $code .= '__print_escaped(do {' . $value . '});';
            }
        }
        elsif ($token->{type} eq 'exec') {
            $code .= $token->{value};
            $code .= ';' unless $token->{line};
        }
        else {
            $code .= '__print(q{' . $token->{value} . '});';
        }
    }

    $code;
}

1;
