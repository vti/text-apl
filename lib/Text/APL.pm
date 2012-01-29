package Text::APL;

use strict;
use warnings;

use base 'Text::APL::Base';

use File::Spec   ();
use Scalar::Util ();

use Text::APL::Compiler;
use Text::APL::Context;
use Text::APL::Parser;
use Text::APL::Reader;
use Text::APL::Translator;
use Text::APL::Writer;
use Text::APL::ParserFactory;

sub BUILD {
    my $self = shift;

    $self->{parser}         ||= Text::APL::Parser->new;
    $self->{translator}     ||= Text::APL::Translator->new;
    $self->{compiler}       ||= Text::APL::Compiler->new;
    $self->{reader}         ||= Text::APL::Reader->new;
    $self->{writer}         ||= Text::APL::Writer->new;
    $self->{parser_factory} ||= Text::APL::ParserFactory->new;
}

sub render {
    my $self = shift;
    my (%params) = @_;

    my $reader = $self->{reader}->build($params{input});
    my $writer = $self->{writer}->build($params{output});

    my $parser_chunked =
      $self->{parser_factory}->build(parser => $self->{parser});

    my $tape = [];

    $reader->(
        sub {
            my ($chunk) = @_;

            if (!defined $chunk) {
                my $leftover = $parser_chunked->parse_chunk_final;
                push @$tape, @$leftover if $leftover;

                my $code = $self->_translate($tape);

                my $context = $self->_build_context_from_args(
                    helpers => {
                        __print         => sub { $writer->(@_) },
                        __print_escaped => sub {
                            my ($input) = @_;

                            for ($input) {
                                s/&/&amp;/g;
                                s/</&lt;/g;
                                s/>/&gt;/g;
                            }

                            $writer->($input);
                        },
                        %{$params{helpers} || {}}
                    },
                    vars => $params{vars}
                );

                my $sub_ref = $self->_compile($code, $context);

                $sub_ref->($context);

                $writer->();
            }
            else {
                my $subtape = $parser_chunked->parse_chunk($chunk);
                push @$tape, @$subtape if @$subtape;
            }
        }
    );

    return $self;
}

sub _translate {
    my $self = shift;

    return $self->{translator}->translate(@_);
}

sub _compile {
    my $self = shift;

    return $self->{compiler}->compile(@_);
}

sub _build_context_from_args {
    my $self = shift;

    if (   @_ == 1
        && Scalar::Util::blessed($_[0])
        && $_[0]->isa('Text::APL::Context'))
    {
        return $_[0];
    }

    return Text::APL::Context->new(@_);
}

1;
