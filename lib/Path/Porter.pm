package Path::Porter;
use strict;
use warnings;
use String::CamelCase qw/camelize/;
use constant TRUE => 1;
use constant FALSE => 0;
use Class::Data::Inheritable;
our $VERSION = '0.01';

sub import {
    my $caller = caller(0);

    no strict 'refs';
    unshift @{"$caller\::ISA"}, 'Class::Data::Inheritable';
    $caller->mk_classdata('dispatch_table' => []);
    *{"$caller\::$_"} = *{$_} for qw/on run camelize_path determine TRUE FALSE/;
}

sub on ($$)  { ## no critic.
    my $class = caller(0);
    $class->dispatch_table( [@{$class->dispatch_table}, { regexp => qr{^$_[0]$}, code => $_[1] }] );
}

sub run (&) {shift} ## no critic.

my $camelize_path_cache;
sub camelize_path {
    my $path = shift;
    if (my $class = $camelize_path_cache->{$path}) {
        return $class;
    } else {
        $camelize_path_cache->{$path} = join '::', map {camelize $_} split '/', $path;
        return $camelize_path_cache->{$path};
    }
}

sub determine {
    my ($class, $path) = @_;

    for my $dispatch_rule (@{$class->dispatch_table}) {
        if ($path =~ $dispatch_rule->{regexp}) {
            my ($controller, $page, $static, $args) = $dispatch_rule->{code}->();
            if ($controller) {
                return +{
                    controller => $controller,
                    action     => $page,
                    is_static  => $static,
                    args       => $args
                };
            } else {
                return;
            }
        }
    }
    return;
}

1;



=head1 NAME

Path::Porter - dispatch path

=head1 SYNOPSIS

    package Your::Dispatcher;
    use Path::Porter;
    
    on '/' => run {
        return 'Root', 'index', FALSE, +{};
    };
    
    on '/(.+)' => run {
        return 'Root', 'index', FALSE, +{ p => $1 };
    };
    
    1;

    # in your script:
    use Your::Dispatcher;
    my $map = Your::Dispatcher->determine($path);

=head1 DESCRIPTION

I'm path porter.

=head1 AUTHOR

Atsushi Kobayashi <nekokak __at__ gmail.com>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
