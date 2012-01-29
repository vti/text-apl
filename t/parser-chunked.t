use strict;
use warnings;

use Test::More;

use Text::APL::ParserChunked;

my $parser;

$parser = Text::APL::ParserChunked->new;
is_deeply $parser->parse(''), [];

$parser = Text::APL::ParserChunked->new;
is_deeply $parser->parse('text'), [];
is_deeply $parser->parse(), [{type => 'text', value => 'text'}];

$parser = Text::APL::ParserChunked->new;
is_deeply $parser->parse('text'), [];
is_deeply $parser->parse('text2'), [];
is_deeply $parser->parse(),
  [{type => 'text', value => 'texttext2'},];

$parser = Text::APL::ParserChunked->new;
is_deeply $parser->parse('<%'), [];
is_deeply $parser->parse('= "hello" %>'),
  [{type => 'expr', value => '"hello"'}];
is_deeply $parser->parse(), [];

done_testing;
