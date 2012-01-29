package Text::APL::Reader;

use strict;
use warnings;

use base 'Text::APL::Base';

sub build {
    my $self = shift;
    my ($input) = @_;

    my $reader;

    if (!ref $input) {
        open my $fh, '<', $input or die "Can't open '$input': $!";

        $reader = sub {
            my ($cb) = @_;
            while (defined(my $line = <$fh>)) {
                $cb->($line);
            }
            $cb->();
        };
    }
    elsif (ref $input eq 'SCALAR') {
        $reader = sub {
            my ($cb) = @_;

            $cb->(${$input});
            $cb->();
        };
    }
    elsif (ref $input eq 'CODE') {
        $reader = $input;
    }
    else {
        die 'Do not know how to read';
    }

    return $reader;
}

1;
