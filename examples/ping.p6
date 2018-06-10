#!/usr/bin/env perl6

use Desktop::Notify :constants;

sub MAIN($server, :$freq = 10, :$timeout = NOTIFY_EXPIRES_DEFAULT)
{
  my $notify = Desktop::Notify.new(app-name => $server);
  my $last;
  loop {
    react {
      my $proc = Proc::Async.new: 'ping', '-c 1', $server;
      whenever $proc.stdout { }
      whenever $proc.stderr { }
      my $promise = $proc.start;
      whenever $promise {
        my $exit = (await $promise).exitcode;
        $last //= $exit;
        if $last != $exit {
          .show: .new-notification(:summary('Attention!'),
            :body("Status changed: {$last ?? 'not responding' !! 'responding'} -> " ~
              "{$exit ?? 'not responding' !! 'responding'}"),
            :icon($exit ?? 'stop' !! 'info'), :$timeout) with $notify;
          $last = $exit;
        }
      }
    }
    once {
      .show: .new-notification(:summary('Initial state'), :body($last ?? 'Not responding' !! 'Responding'),
        :icon($last ?? 'stop' !! 'info'), :$timeout) with $notify
    }
    sleep $freq;
  }
}
