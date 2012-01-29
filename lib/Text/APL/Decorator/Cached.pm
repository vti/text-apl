package Text::APL::Decorator::Cached;

use strict;
use warnings;

use base 'Text::APL::Decorator::Base';

use File::Spec;
use File::Temp ();
use File::Path ();
use File::Basename ();

sub BUILD {
    my $self = shift;

    $self->{cache_dir} ||= File::Temp::tempdir;
}

sub render_file {
    my $self = shift;
    my ($file) = @_;

    my $cache_file =
      File::Spec->catfile($self->{cache_dir}, File::Spec->rel2abs($file));

    if (-e $cache_file) {
        open my $fh, '<', $cache_file
          or die "Can't read cached file '$cache_file': $!";
        sysread $fh, my $output, -s $cache_file;
        return $output;
    }

    my $output = $self->{object}->render_file(@_);

    my $cache_dir = File::Basename::dirname($cache_file);
    if (!-d $cache_dir) {
        File::Path::make_path($cache_dir);
    }

    open my $fh, '>', $cache_file
      or die "Can't write cache file '$cache_file': $!";
    print $fh $output;

    return $output;
}

1;
