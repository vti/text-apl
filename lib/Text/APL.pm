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

sub _BUILD {
    my $self = shift;

    $self->{parser}         ||= Text::APL::Parser->new;
    $self->{translator}     ||= Text::APL::Translator->new;
    $self->{compiler}       ||= Text::APL::Compiler->new;
    $self->{reader}         ||= $self->_build_reader;
    $self->{writer}         ||= Text::APL::Writer->new;
}

sub render {
    my $self = shift;
    my (%params) = @_;

    my $return = '';

    my $writer =
      $self->{writer}
      ->build(exists $params{output} ? $params{output} : \$return);

    my $context = Text::APL::Context->new(
        helpers => $params{helpers},
        vars    => $params{vars}
    );
    $context->add_helper(__print => sub { $writer->(@_) });
    $context->add_helper(
        __print_escaped => sub {
            my ($input) = @_;

            for ($input) { s/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g; }

            $writer->($input);
        }
    );

    $self->_compile(
        $params{input}, $context, sub {
            my $self = shift;
            my ($sub_ref) = @_;

            $sub_ref->($context);

            $writer->();
        }
    );

    return exists $params{output} ? $self : $return;
}

sub _compile {
    my $self = shift;
    my ($input, $context, $cb) = @_;

    $self->_parse(
        $input => sub {
            my $self = shift;
            my ($tape) = @_;

            my $code = $self->{translator}->translate($tape);

            my $sub_ref = $self->{compiler}->compile($code, $context);

            $cb->($self, $sub_ref);
        }
    );
}

sub _parse {
    my $self = shift;
    my ($input, $cb) = @_;

    my $parser = $self->{parser};

    my $reader = $self->{reader}->build($input);

    my $tape = [];
    my $reader_cb = sub {
        my ($chunk) = @_;

        if (!defined $chunk) {
            my $leftover = $parser->parse();
            push @$tape, @$leftover if $leftover;

            $cb->($self, $tape);
        }
        else {
            my $subtape = $parser->parse($chunk);
            push @$tape, @$subtape if @$subtape;
        }
    };

    $reader->($reader_cb, $input);
}

sub _build_reader {
    my $self = shift;

    return exists $INC{"AnyEvent.pm"}
      ? do {
        require AnyEvent::AIO;
        require Text::APL::Reader::AIO;
        Text::APL::Reader::AIO->new;
      }
      : exists $INC{"IO/AIO.pm"}
      ? do { require TExt::APL::Reader::AIO; Text::APL::Reader->AIO->new }
      : Text::APL::Reader->new;
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

This for example works just fine:

    $parser->parse('<% $hello');
    $parser->parse(' %>');

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
