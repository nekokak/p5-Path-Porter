use strict;
use warnings;
use Test::More;

plan tests => 3;

{
    package Mock::Dispatcher;
    use Path::Porter;
    on '/' => run {
        return 'Root', 'index', FALSE, +{};
    };
    on '/(.+).html' => run {
        return 'Root', 'index', TRUE, +{ p => $1 };
    };
    on '/(.+)' => run {
        return 'Root', 'index', FALSE, +{ p => $1 };
    };
    1;
}

is_deeply +Mock::Dispatcher->determine('/'), +{
    controller => 'Root',
    action     => 'index',
    is_static  => 0,
    args       => {},
};

is_deeply +Mock::Dispatcher->determine('/foo'), +{
    controller => 'Root',
    action     => 'index',
    is_static  => 0,
    args       => {p => 'foo'},
};

is_deeply +Mock::Dispatcher->determine('/bar.html'), +{
    controller => 'Root',
    action     => 'index',
    is_static  => 1,
    args       => {p => 'bar'},
};

