use strict;
use warnings;

use Test::More;

use Text::APL::Parser;

my $parser;

$parser = Text::APL::Parser->new;
is_deeply $parser->parse(''), [];

$parser = Text::APL::Parser->new;
is_deeply $parser->parse('text'), [{type => 'text', value => 'text'}];

$parser = Text::APL::Parser->new;
is_deeply $parser->parse('<%= $foo %>'),
  [{type => 'expr', value => '$foo'}];

$parser = Text::APL::Parser->new;
is_deeply $parser->parse('<%== $foo %>'), [{type => 'expr', value => '$foo', as_is => 1}];

$parser = Text::APL::Parser->new;
is_deeply $parser->parse('%= $foo'),
  [{type => 'expr', value => '$foo', line => 1}];

$parser = Text::APL::Parser->new;
is_deeply $parser->parse('%== $foo'),
  [{type => 'expr', value => '$foo', line => 1, as_is => 1}];

$parser = Text::APL::Parser->new;
is_deeply $parser->parse('<% $foo %>'), [{type => 'exec', value => '$foo'}];

$parser = Text::APL::Parser->new;
is_deeply $parser->parse('% $foo'),
  [{type => 'exec', value => '$foo', line => 1}];

$parser = Text::APL::Parser->new;
is_deeply $parser->parse(<<'EOF'),
And text <%= $foo %> all
<%== $foo %> over
the <% $foo %> place
    %= $foo
one
        %== $foo
two
    % $foo
three
EOF
  [ {type => 'text', value => 'And text '},
    {type => 'expr', value => '$foo'},
    {type => 'text', value => " all\n"},
    {type => 'expr', value => '$foo', as_is => 1},
    {type => 'text', value => " over\nthe "},
    {type => 'exec', value => '$foo'},
    {type => 'text', value => " place"},
    {type => 'expr', value => '$foo', line => 1},
    {type => 'text', value => "\none"},
    {type => 'expr', value => '$foo', line => 1, as_is => 1},
    {type => 'text', value => "\ntwo"},
    {type => 'exec', value => '$foo', line => 1},
    {type => 'text', value => "\nthree\n"},
  ];

done_testing;
