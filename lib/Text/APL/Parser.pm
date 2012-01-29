package Text::APL::Parser;

use strict;
use warnings;

use base 'Text::APL::Base';

sub _BUILD {
    my $self = shift;

    $self->{start_token} ||= '<%';
    $self->{end_token}   ||= '%>';

    $self->{line_token} ||= '%';

    return $self;
}

sub parse {
    my $self = shift;
    my ($input) = @_;

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
            push @$tape,
              {type => 'text', value => substr($input, pos($input))};
            last;
        }
    }

    $tape;
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
