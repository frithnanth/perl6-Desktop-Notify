use v6;

unit class Desktop::Notify:ver<1.0.1>:auth<zef:FRITH>;

use Desktop::Notify::Raw;
use NativeCall;

has GError $.error is rw;
has GList $.glist is rw;

enum NotifyUrgency is export(:constants) <NotifyUrgencyLow NotifyUrgencyNormal NotifyUrgencyCritical>;

constant NOTIFY_EXPIRES_DEFAULT is export(:constants) = -1;
constant NOTIFY_EXPIRES_NEVER   is export(:constants) =  0;

submethod BUILD(:$app-name!) { notify_init($app-name); $!error = GError.new }
submethod DESTROY { notify_uninit(); $!error.free };

method is-initted(--> Bool) { notify_is_initted.Bool }
multi method app-name(--> Str) { notify_get_app_name }
multi method app-name(Str $appname!)
{
  notify_set_app_name($appname);
  self;
}
multi method new-notification(Str $summary!, Str $body!, Str $icon! --> NotifyNotification)
{
  notify_notification_new($summary, $body, $icon);
}
multi method new-notification(Str :$summary!,
                              Str :$body!,
                              Str :$icon!,
                              Int :$timeout?,
                              Str :$category?,
                              NotifyUrgency :$urgency?
                              --> NotifyNotification)
{
  my NotifyNotification $n = notify_notification_new($summary, $body, $icon);
  notify_notification_set_timeout($n, $timeout)   with $timeout;
  notify_notification_set_category($n, $category) with $category;
  notify_notification_set_urgency($n, $urgency)   with $urgency;
  return $n;
}

method show(NotifyNotification $notification!, GError $err? --> Bool)
{
  notify_notification_show($notification, $err // $!error).Bool;
}
method close(NotifyNotification $notification!, GError $err? --> Bool)
{
  notify_notification_close($notification, $err // $!error).Bool;
}
method add-action(NotifyNotification $notification!, Str $action, Str $label, &callback (NotifyNotification $notification1, Str $action1))
{
  notify_notification_add_action($notification, $action, $label, callback);
  self;
}
method get-type(--> Int)
{
  notify_notification_get_type();
}
method update(NotifyNotification $notification!, Str $summary, Str $body, Str $icon --> Bool)
{
  notify_notification_update($notification, $summary, $body, $icon).Bool;
}
method set-timeout(NotifyNotification $notification!, Int $timeout!)
{
  notify_notification_set_timeout($notification, $timeout);
  self;
}
method set-category(NotifyNotification $notification!, Str $category!)
{
  notify_notification_set_category($notification, $category);
  self;
}
method set-urgency(NotifyNotification $notification!, NotifyUrgency $urgency!)
{
  notify_notification_set_urgency($notification, $urgency);
  self;
}
method why-closed(NotifyNotification $notification! --> Int)
{
  notify_notification_get_closed_reason($notification);
}
method server-caps(--> Seq)
{
  $!glist = notify_get_server_caps();
  my GList $l = self.glist;
  gather loop {
    take nativecast(Str, $l.data);
    last unless $l.next;
    $l = $l.next;
  }
}
method server-info(--> Hash)
{
  my $name = Pointer[Str].new;
  my $vendor = Pointer[Str].new;
  my $version = Pointer[Str].new;
  my $spec-version = Pointer[Str].new;
  my $ret = notify_get_server_info($name, $vendor, $version, $spec-version).Bool;
  return { return       => $ret,
           name         => nativecast(Str, $name),
           vendor       => nativecast(Str, $vendor),
           version      => Version.new(nativecast(Str, $version)),
           spec-version => Version.new(nativecast(Str, $spec-version)),
         };
}

=begin pod

=head1 NAME

Desktop::Notify - A simple interface to libnotify

=head1 SYNOPSIS

=begin code :lang<raku>

use Desktop::Notify::Simple;

my $n = Desktop::Notify::Simple.new(
  :app-name('test'),
  :summary('Attention!'),
  :body('What just happened?'),
  :icon('stop')
).show;

sleep 2;

$n.update(:summary('Oh well!'), :body('Not quite a disaster!'), :icon('stop')).show;

=end code

=begin code :lang<raku>

use Desktop::Notify :constants;

my $notify = Desktop::Notify.new(app-name => 'myapp');
my $n = $notify.new-notification('Attention!', 'What just happened?', 'stop');

$notify.set-timeout($n, NOTIFY_EXPIRES_NEVER);

$notify.show($n);
sleep 2;

$notify.update($n, 'Oh well!', 'Not quite a disaster!', 'stop');

$notify.show($n);

=end code

=head1 DESCRIPTION

=head2 B<Desktop::Notify::Simple> is a set of very simple bindings to libnotify using NativeCall.

=head3 new(Str :$app-name!, Str :$summary!, Str :$body!, Str :$icon!, Int :$timeout?, Str :$category?, NotifyUrgency :$urgency?)

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

=head3 show(GError $err?)

Shows the notification on screen. It takes one optional argument, the GError object.
(The default Desktop::Notify error handling is not thread safe. See I<Threading safety> for more info)

=head3 update(Str :$summary, Str :$body, Str :$icon)

Modifies the messages of a notification which is already on screen.

=head3 close(GError $err?)

Closes the notification. It takes one optional argument, the GError object. (The default Desktop::Notify error
handling is not thread safe. See I<Threading safety> for more info)
Note that usually there's no need to explicitly 'close' a notification, since the default is to automatically
expire after a while.

=head2 B<Desktop::Notify> is a set of simple bindings to libnotify using NativeCall. Some
function calls are not currently implemented (see the I<TODO> section).

=head3 new(Str $appname)

Constructs a new B<Desktop::Notify> object. It takes one mandatory argument:
B<app-name>, the name of the app that will be registered with the notify dæmon.

=head3 is-initted(--> Bool)

Returns True if the object has been successfully initialized.

=head3 app-name(--> Str)
=head3 app-name(Str $appname)

Queries or sets the app name.

=head3 new-notification(Str $summary!, Str $body!, Str $icon! --> NotifyNotification)
=head3 new-notification(Str :$summary!, Str :$body!, Str :$icon!, Int :$timeout?, Str :$category?, NotifyUrgency :$urgency?  --> NotifyNotification)

Creates a new notification.
The first form takes three positional arguments: the summary string, the notification string and
the icon to display (See the libnotify documentation for the available icons).
The second form takes a number of named argument. B<summary>, B<body>, and B<icon> are I<mandatory>,
the others are optional. If B<timeout> (expressed in milliseconds), B<category>, and B<urgency> are defined,
this method will call the corresponding "set" methods documented below.

=head3 show(NotifyNotification $notification!, GError $err? --> Bool)

Shows the notification on screen. It takes one mandatory argument, the
NotifyNotification object, and one optional argument, the GError object.
(The default Desktop::Notify error handling is not thread safe. See
I<Threading safety> for more info)

=head3 close(NotifyNotification $notification!, GError $err? --> Bool)

Closes the notification. It takes one mandatory argument, the NotifyNotification
object, and one optional argument, the GError object. (The default
Desktop::Notify error handling is not thread safe. See I<Threading safety> for
more info)
Note that usually there's no need to explicitly 'close' a notification, since
the default is to automatically expire after a while.

=head3 why-closed(NotifyNotification $notification! --> Int)

Returns the the closed reason code for the notification. It takes one argument,
the NotifyNotification object. (See the libnotify documentation for the meaning of
this code)

=head3 get-type(--> Int)

Returns the notification type.

=head3 update(NotifyNotification $notification!, Str $summary, Str $body, Str $icon --> Bool)

Modifies the messages of a notification which is already on screen.

=head3 set-timeout(NotifyNotification $notification!, Int $timeout!)

Sets the notification timeout. There are two available constants,
B<NOTIFY_EXPIRES_DEFAULT> and B<NOTIFY_EXPIRES_NEVER>, when explicitly imported
with B<use Desktop::Notify :constants;>.


=head3 set-category(NotifyNotification $notification, Str $category!)

Sets the notification category (See the libnotify documentation).

=head3 set-urgency(NotifyNotification $notification, NotifyUrgency $urgency!)

Sets the notification urgency. An B<enum NotifyUrgency <NotifyUrgencyLow NotifyUrgencyNormal NotifyUrgencyCritical>>
is available when explicitly imported with B<use Desktop::Notify :constants;>.

=head3 server-caps(--> Seq)

Reads server capabilities and returns a sequence.

=head3 server-info(--> Hash)

Reads the server info and returns an hash. The return value of the C function call is
returned as the value of the B<return> key of the hash.

=head1 Threading safety

Desktop::Notify offers a simple interface which provides an B<error> class member,
which is automatically used by the functions which need it.
Since 'error' is a shared class member, if a program makes use of threading, its value
might be written by another thread before it's been read.
In this case one can declare their own GError variables:

=begin code :lang<raku>
my $err = Desktop::Notify::GError.new;
=end code

and pass it as an optional argument to the .show() and .close() methods; it will be
used instead of the object-wide one.

=head1 Prerequisites

This module requires the libnotify library to be installed. Please follow the
instructions below based on your platform:

=head2 Debian and Ubuntu

=begin code
sudo apt install libnotify4
=end code

=head1 Installation

=begin code
$ zef install Desktop::Notify
=end code

=head1 Testing

To run the tests:

=begin code
$ prove -e "raku -Ilib"
=end code

=head1 Note

With version 0.2.0 I modified the B<enum NotifyUrgency> to avoid polluting (too much) the namespace.
Now instead of e.g. B<low>, one has to use B<NotifyUrgencyLow>.

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
