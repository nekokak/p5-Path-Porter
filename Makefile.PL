use inc::Module::Install;
name 'Path-Porter';
all_from 'lib/Path/Porter.pm';

requires 'Class::Data::Inheritable';
requires 'String::CamelCase';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
