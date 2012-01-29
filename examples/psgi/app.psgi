use strict;
use warnings;

use Plack::Builder;

use File::Basename ();
use File::Spec;
use AnyEvent::Handle;
use AnyEvent::AIO;
use IO::AIO;

use Text::APL;

my $template       = Text::APL->new;
my $templates_path = File::Basename::dirname(__FILE__);

my $app = sub {
    my ($env) = @_;

    return sub {
        my ($respond) = @_;

        my $writer = $respond->([200, ['Content-Type' => 'text/html']]);

        my $handle;

        my $path_to_template =
          File::Spec->rel2abs(
            File::Spec->catfile($templates_path, 'template.apl'));

        aio_open $path_to_template, IO::AIO::O_RDONLY, 0, sub {
            my $fh = shift or die "$!";

            $template->render(
                input => sub {
                    my ($cb) = @_;

                    $handle = AnyEvent::Handle->new(
                        fh      => $fh,
                        on_eof  => sub { $cb->() },
                        on_read => sub {
                            my $handle = shift;

                            $handle->push_read(
                                line => sub {
                                    my ($handle, $line) = @_;

                                    $cb->($line);
                                }
                            );
                        },
                        on_error => sub { }
                    );

                },
                output => sub {
                    my ($chunk) = @_;

                    if (defined $chunk) {
                        $writer->write($chunk);
                    }
                    else {
                        $writer->close;
                    }
                },
                vars => {name => 'vti'}
            );
        };
    };
};

builder {
    enable 'Chunked';

    $app;
};
