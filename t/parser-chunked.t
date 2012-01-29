use strict;
use warnings;

use Test::More;

use Text::APL::ParserChunked;

my $parser;

$parser = Text::APL::ParserChunked->new;
is_deeply $parser->parse_chunk(''), [];

$parser = Text::APL::ParserChunked->new;
is_deeply $parser->parse_chunk('text'), [];
is_deeply $parser->parse_chunk_final(''), [{type => 'text', value => 'text'}];

$parser = Text::APL::ParserChunked->new;
is_deeply $parser->parse_chunk('text'), [];
is_deeply $parser->parse_chunk_final('text2'),
  [{type => 'text', value => 'texttext2'},];

$parser = Text::APL::ParserChunked->new;
is_deeply $parser->parse_chunk('<%'), [];
is_deeply $parser->parse_chunk_final('= "hello" %>'),
  [{type => 'expr', value => '"hello"'}];

done_testing;
