## Desktop::Notify

Desktop::Notify is a set of simple bindings to libnotify using NativeCall. Only
a few function calls are currently implemented, however these are enough to
create and display notifications.

## Example

```Perl6
use v6;
use Desktop::Notify;

my $notify = Desktop::Notify.new(app-name => 'myapp');
my $n = $notify.new-notification('Attention!', 'What just happened?', 'stop');

$notify.set-timeout($n, NOTIFY_EXPIRES_NEVER);

$notify.show-notification($n);
sleep 2;

$notify.update-notification($n, 'Oh well!', 'Not quite a disaster!', 'stop');

$notify.show-notification($n);
```

If you're trying this code, note that the notification doesn't fade by itself,
but you need to click on it in order to close it.

## Documentation

#### new(Str $appname)

Constructs a new `Desktop::Notify` object. It takes one **mandatory** argument:
`app-name`, the name of the app that will be registered with the notify dæmon.

#### is-initted

Returns True if the object has been successfully initialized.

#### app-name(--> Str)
#### app-name(Str $appname)

Queries or sets the app name.

#### new-notification(Str $summary, Str $body, Str $icon --> NotifyNotification)

Creates a new notification. It takes three **mandatory** arguments: the summary
string, the notification string and the icon to display (See the libnotify
documentation for the available icons).

#### show-notification(NotifyNotification $notification, GError $error is rw --> Bool)

Shows the notification on screen. It takes two arguments, the NotifyNotification
object and the GError object. The status is returned in the GError object.

#### get-type(--> Int)

Returns the notification type.

#### update-notification(NotifyNotification $notification, Str $summary, Str $body, Str $icon --> Bool)

Modifies the messages of a notification which is already on screen.

#### set-timeout(NotifyNotification $notification, Int $timeout)

Sets the notification timeout. There are two available constants:
`NOTIFY_EXPIRES_DEFAULT` and `NOTIFY_EXPIRES_NEVER`.

#### set-category(NotifyNotification $notification, Str $category)

Sets the notification category (See the libnotify documentation).

#### set-urgency(NotifyNotification $notification, NotifyUrgency $urgency)

Sets the notification urgency. There an available `enum NotifyUrgency <low normal critical>`.

## Prerequisites
This module requires the libnotify library to be installed. Please follow the
instructions below based on your platform:

### Debian Linux

```
sudo apt-get install libnotify4
```

The module looks for a library called libnotify.so.4, or whatever it finds in
the environment variable ```PERL6_NOTIFY_LIB``` (provided that the library you
choose uses the same API).

## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

```
$ panda update
$ panda install Desktop::Notify
```

## Testing

To run tests:

```
$ prove -e "perl6 -Ilib"
```

or

```
$ prove6
```

## Author

Fernando Santagata

## License

The Artistic License 2.0
