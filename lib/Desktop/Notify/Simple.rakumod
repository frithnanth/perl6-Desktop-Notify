use v6;

unit class Desktop::Notify::Simple:ver<1.0.0>:auth<cpan:FRITH>;

use Desktop::Notify::Raw;
use NativeCall;

has GError $.error is rw;
has GList $.glist is rw;
has NotifyNotification $!n;

enum NotifyUrgency is export <NotifyUrgencyLow NotifyUrgencyNormal NotifyUrgencyCritical>;

constant NOTIFY_EXPIRES_DEFAULT is export = -1;
constant NOTIFY_EXPIRES_NEVER   is export =  0;

submethod BUILD(Str :$app-name!,
                 Str :$summary!,
                 Str :$body!,
                 Str :$icon!,
                 Int :$timeout?,
                 Str :$category?,
                 NotifyUrgency :$urgency?)
{
  notify_init($app-name); $!error = GError.new;
  $!n = notify_notification_new($summary, $body, $icon);
  notify_notification_set_timeout($!n, $timeout * 1000)   with $timeout;
  notify_notification_set_category($!n, $category) with $category;
  notify_notification_set_urgency($!n, $urgency)   with $urgency;
}

submethod DESTROY { notify_uninit(); $!error.free };

method show(GError $err?)
{
  notify_notification_show($!n, $err // $!error);
  self
}

method close(GError $err?)
{
  notify_notification_close($!n, $err // $!error);
  self
}
method update(Str :$summary, Str :$body, Str :$icon)
{
  notify_notification_update($!n, $summary, $body, $icon);
  self
}

=begin pod

=head1 NAME

Desktop::Notify::Simple - A simpler interface to libnotify

=head1 SYNOPSIS
=begin code

use Desktop::Notify::Simple;

my $n = Desktop::Notify::Simple.new(
  :app-name('testone'),
  :summary('Attention!'),
  :body('What just happened?'),
  :icon('stop')
).show;

sleep 2;

$n.update(:summary('Oh well!'), :body('Not quite a disaster!'), :icon('stop')).show;

=end code

=head1 DESCRIPTION

B<Desktop::Notify::Simple> is a set of very simple bindings to libnotify using NativeCall.

=head2 new(Str :$app-name!, Str :$summary!, Str :$body!, Str :$icon!, Int :$timeout?, Str :$category?, NotifyUrgency :$urgency?)

Constructs a new B<Desktop::Notify::Simple> object. It takes four mandatory arguments:

=item $app-name the name of the app that will be registered with the notify dæmon.
=item $summary  appears in bold on the top side of the notification
=item $body     notification body
=item $icon     icon name

and three optional arguments:

=item $timeout   expressed in seconds (while Desktop::Notify uses milliseconds)
=item $category  can be used by the notification server to filter or display the data in a certain way
=item $urgency   urgency level of this notification

An B<enum NotifyUrgency <NotifyUrgencyLow NotifyUrgencyNormal NotifyUrgencyCritical>> is available.

=head2 show(GError $err?)

Shows the notification on screen. It takes one optional argument, the GError object.
(The default Desktop::Notify error handling is not thread safe. See I<Threading safety> for more info)

=head2 update(Str :$summary, Str :$body, Str :$icon)

Modifies the messages of a notification which is already on screen.

=head2 close(GError $err?)

Closes the notification. It takes one optional argument, the GError object. (The default Desktop::Notify error
handling is not thread safe. See I<Threading safety> for more info)
Note that usually there's no need to explicitly 'close' a notification, since the default is to automatically
expire after a while.

=head1 Threading safety

Desktop::Notify offers a simple interface which provides an B<error> class member, which is automatically used by
the functions which need it.
Since 'error' is a shared class member, if a program makes use of threading, its value might be written by another
thread before it's been read.
In this case one can declare their own GError variables:

=begin code
my $err = Desktop::Notify::Raw::GError.new;
=end code

and pass it as an optional argument to the .show() and .close() methods; it will be used instead of the object-wide one.

=head1 Prerequisites

This module requires the libnotify library to be installed. Please follow the instructions below based on your platform:

=head2 Debian Linux

=begin code
sudo apt-get install libnotify4
=end code

=head1 Installation

=begin code
$ zef install Desktop::Notify
=end code

=head1 Testing

To run the tests:

=begin code
$ prove -e "perl6 -Ilib"
=end code

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
