package Text::APL::Context;

use strict;
use warnings;

use base 'Text::APL::Base';

sub _BUILD {
    my $self = shift;

    $self->{vars}    ||= {};
    $self->{helpers} ||= {};
}

sub vars    { $_[0]->{vars} }
sub helpers { $_[0]->{helpers} }

1;
__END__

=pod

=head1 NAME

Text::APL::Context - value object

=head1 DESCRIPTION

Used internally for passing variables and helpers to the template.

=head1 METHODS

=head2 C<new>

    my $template = Text::APL::Context->new;

Create new L<Text::APL::Context> instance.

=head2 C<vars>

Returns variables.

=head2 C<helpers>

Returns helpers.

=cut
