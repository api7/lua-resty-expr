package t::Expr;

use lib 'lib';

use Test::Nginx::Socket::Lua::Stream -Base;

repeat_each(2);
log_level('info');
no_long_string();
no_shuffle();

my $pwd = `pwd`;
chomp $pwd;

add_block_preprocessor(sub {
    my ($block) = @_;

    my $http_config = $block->http_config // '';
    $http_config = <<_EOC_;
    lua_package_path '$pwd/t/lib/?.lua;$pwd/lib/?.lua;$pwd/deps/share/lua/5.1/?.lua;\$prefix/?.lua;;';
    lua_package_cpath '$pwd/?.so;;';

    $http_config
_EOC_

    $block->set_value("http_config", $http_config);

    if (!(defined $block->no_error_log) && ! defined $block->error_log) {
        $block->set_value("no_error_log", "[error]");
    }

    if (! defined $block->request) {
        $block->set_value("request", "GET /t");
    }
});

1;
