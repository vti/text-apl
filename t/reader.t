use strict;
use warnings;

use Test::More;

use Text::APL::Reader;

my $stack;
my $reader;

is_deeply reader(\'foo'), ['foo', undef];

is_deeply reader('t/template'), ["Hello.\n", undef];

open my $fh, '<', 't/template';
is_deeply reader($fh), ["Hello.\n", undef];
close $fh;

is_deeply reader(sub { $_[0]->('foo') }), ['foo'];

sub reader {
    my @args  = @_;
    my $stack = [];
    $reader = Text::APL::Reader->new->build(@_);
    $reader->(sub { push @$stack, $_[0] });
    return $stack;
}

done_testing;
