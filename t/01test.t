#!/usr/bin/env perl6

use Test;
use lib 'lib';
use Desktop::Notify;

constant AUTHOR = ?%*ENV<TEST_AUTHOR>;

my $notify = Desktop::Notify.new(app-name => 'testone');

ok { defined $notify }, 'initialization';
ok $notify.is-initted, "is-initted method";
is $notify.app-name, 'testone', 'reading app name';

$notify.app-name('testtwo');

is $notify.app-name, 'testtwo', 'writing app name';

my $n = $notify.new-notification('Attention!', 'What just happened?', 'stop');
my $error = Desktop::Notify::GError.new;

is $n.WHAT, Desktop::Notify::NotifyNotification, 'creating a notification';
is $error.WHAT, Desktop::Notify::GError, 'creating a GError';
if AUTHOR {
  ok $notify.show-notification($n, $error), 'showing the notification';
  # Does it show on screen? :-)
  sleep 1;
}else{
  skip 'skip showing the notification', 1;
}

ok $notify.update-notification($n, 'Oh well!', 'Not quite a disaster!', 'stop'), 'changing the message';
if AUTHOR {
  ok $notify.show-notification($n, $error), 'showing the modified message';
}else{
  skip 'skip showing the notification', 1;
}

is $notify.get-type.WHAT, Int, 'get-type method';

done-testing;
