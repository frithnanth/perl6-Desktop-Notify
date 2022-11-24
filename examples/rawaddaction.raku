#!/usr/bin/env raku

use lib 'lib';
use Desktop::Notify::Raw;

sub callme($n, $action)
{
  say "Action: $action";
}

notify_init('myapp');
my $n = notify_notification_new('Attention!', 'Problems ahead', 'stop');
notify_notification_add_action($n, 'default', 'Opening...', &callme);
my $err = GError.new;
notify_notification_show($n, $err);
