#!/usr/bin/env perl6

use lib 'lib';
use Desktop::Notify;

my $notify = Desktop::Notify.new(app-name => 'myapp');
my $n = $notify.new-notification('Attention!', 'What just happened?', 'stop');

$notify.set-timeout($n, NOTIFY_EXPIRES_NEVER);

$notify.show($n);
if $notify.error.code != 0 {
  warn 'something bad happened contacting the notify server';
}
sleep 2;

$notify.update($n, 'Oh well!', 'Not quite a disaster!', 'stop');

$notify.show($n);
if $notify.error.code != 0 {
  warn 'something bad happened contacting the notify server';
}
sleep 2;
$notify.close($n);
if $notify.error.code != 0 {
  warn 'something bad happened closing the notification';
}
