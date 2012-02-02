package Text::APL::Parser;

use strict;
use warnings;

use base 'Text::APL::Base';

sub _BUILD {
    my $self = shift;

    $self->{start_token} ||= '<%';
    $self->{end_token}   ||= '%>';

    $self->{line_token} ||= '%';

    $self->{leftover_token} = $self->_build_leftover_pattern;

    return $self;
}

sub parse {
    my $self = shift;
    my ($input) = @_;

    if (!defined $input) {
        return [] unless defined $self->{buffer};
        return [{type => 'text', value => delete $self->{buffer}}];
    }

    if (defined $self->{buffer}) {
        $input = delete($self->{buffer}) . $input;
    }

    my $tape = [];

    pos $input = 0;
    while (pos $input < length $input) {
        if ($input
            =~ m/\G $self->{start_token}(==?)? [ ] (.*?) \s* $self->{end_token}/gcxms
          )
        {
            push @$tape, {type => defined $1 ? 'expr' : 'exec', value => $2};
            $tape->[-1]->{as_is} = 1 if defined $1 && length $1 == 2;
        }
        elsif (
            $input =~ m/\G ^ \s * $self->{line_token}(==?)? [ ] (.*?) $/gcxms)
        {
            chomp $tape->[-1]->{value} if @$tape;
            push @$tape,
              {type => defined $1 ? 'expr' : 'exec', value => $2, line => 1};
            $tape->[-1]->{as_is} = 1 if defined $1 && length $1 == 2;
        }
        elsif ($input
            =~ m/\G (.+?) (?=$self->{start_token}| ^ \s* $self->{line_token})/gcxms
          )
        {
            push @$tape, {type => 'text', value => $1};
        }
        else {
            if ($input
                =~ m/( (?:$self->{start_token} |^ \s* $self->{line_token}) .* )/gcxms
              )
            {
                $self->{buffer} = $1;
            }
            elsif ($input =~ m/( $self->{leftover_token} ) $/gcxms) {
                $self->{buffer} = $1;
            }

            my $value = substr($input, pos($input));

            if (defined $value && $value ne '') {
                push @$tape, {type => 'text', value => $value};
            }

            last;
        }
    }

    $tape;
}

sub _build_leftover_pattern {
    my $self = shift;

    my @token = split //, $self->{start_token};
    my $pattern = '';
    $pattern .= '(?:' . $_ for @token;
    $pattern .= ')?' for @token;
    $pattern =~ s{\?$}{};

    return qr/$pattern/;
}

1;
__END__

=pod

=head1 NAME

Text::APL::Parser - parser

=head1 DESCRIPTION

The actual parser. Parses template into a token tree.

=head1 ATTRIBUTES

=head2 C<start_token>

C<<%> by default.

=head2 C<end_token>

C<%>> by default.

=head2 C<line_token>

C<%> by default.

=head1 METHODS

=head2 C<parse>

Parsers string into a token tree.

=cut
