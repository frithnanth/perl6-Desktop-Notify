#!/usr/bin/env perl6

#use lib 'lib';
use Desktop::Notify;

my $notify = Desktop::Notify.new(app-name => 'myapp');
my $n = $notify.new-notification('Attention!', 'What just happened?', 'stop');

$notify.set-timeout($n, NOTIFY_EXPIRES_NEVER);

my $error = Desktop::Notify::GError.new;

$notify.show-notification($n, $error);
sleep 2;

$notify.update-notification($n, 'Oh well!', 'Not quite a disaster!', 'stop');

$notify.show-notification($n, $error);
