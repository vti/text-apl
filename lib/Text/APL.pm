package Text::APL;

use strict;
use warnings;

use base 'Text::APL::Base';

our $VERSION = 0.01;

use File::Spec   ();
use Scalar::Util ();

use Text::APL::Compiler;
use Text::APL::Context;
use Text::APL::Parser;
use Text::APL::Reader;
use Text::APL::Translator;
use Text::APL::Writer;
use Text::APL::ParserFactory;

sub _BUILD {
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
                my $leftover = $parser_chunked->parse();
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
                my $subtape = $parser_chunked->parse($chunk);
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
__END__

=pod

=head1 NAME

Text::APL - non-blocking and streaming capable template engine

=head1 SYNOPSIS

=head2 Simple example

    $template->render(
        input  => \$input,
        output => \$output,
        vars   => {foo => 'bar'}
    );

=head2 Streaming example

    $template->render(
        input => sub {
            my ($cb) = @_;

            # Call $cb($data) when data is available
            # Call $cb->() on EOF
        },
        output => sub {
            my ($chunk) = @_;

            # Print $chunk to the needed output
            # $chunk is undef when template is fully rendered
        },
        vars => {foo => 'bar'}
    );

=head1 DESCRIPTION

This is yet another template engine. But compared to others it supports
non-blocking (read/write) and streaming output.

=head2 Reader/Writer

Reader and writer can be a subroutine references reading from any source and
writing output to any destination. Sane default implementations for reading from
a string, a file or file handle and writing to the string, a file or a file
handle are also available.

=head2 Parser

Parser can parse not only full templates but chunk by chunk correctly resolving
any ambiguous leftovers. This allows immediate parsing.

=head2 Compiler

Compiler compiles templates into Perl code but when evaluating does not create
a Perl string that accumulates all the template output, but rather provides
a special C<print> function that pushes the content as soon as it's available
(streaming).

The generated Perl code can looks like this:

    Hello, <%= $nickname %>!

    # becomes

    __print(q{Hello, });
    __print_escaped(do {$foo});
    __print(q{!});

=head1 SYNTAX

Syntax is borrowed from the template standards shared among several web
framewoks in different languages:

    <% foo() %> # evaluate code
    % foo()

    <%= $foo %> # insert evaluation result
    %= $foo

    <%== $foo %> # insert evaluation result without escaping
    %== %foo

No new template language is provided, just the old Perl.

=head1 METHODS

=head2 C<new>

    my $template = Text::APL->new;

Create new L<Text::APL> instance.

Accepted options:

=over

=item * parser (by default L<Text::APL::Parser>)

=item * parser_factory (by default L<Text::APL::ParserFactory>)

=item * translator (by default L<Text::APL::Translator>)

=item * compiler (by default L<Text::APL::Compiler>)

=item * reader (by default L<Text::APL::Reader>)

=item * writer (by default L<Text::APL::Writer>)

=back

=head2 C<render>

    $template->render(
        input   => \$input,
        output  => \$output,
        vars    => {foo => 'bar'},
        helpers => {
            time => sub {time}
        }
    );

C<input> and C<output> can be a filename, a reference to scalar, a file handle
and a reference to subroutine. Read more at L<Text::APL::Reader> and
L<Text::APL::Writer>.

C<vars> are Perl variables available in the template.

C<helpers> are Perl subroutines. available in the template.

=head1 EXAMPLES

For working examples see C<examples/> directory in distribution.

=head1 DEVELOPMENT

=head2 Repository

    http://github.com/vti/text-apl

=head1 AUTHOR

Viacheslav Tykhanovskyi, C<vti@cpan.org>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012, Viacheslav Tykhanovskyi

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
