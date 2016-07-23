#!/usr/bin/env perl6

unit class Desktop::Notify;

use NativeCall;

constant LIB = %*ENV<PERL6_NOTIFY_LIB> || 'libnotify.so.4';

class NotifyNotification is repr('CPointer') { * } # libnotify private struct
class GError is repr('CStruct') {
  has int64 $.domain;
  has int32 $.code;
  has Str   $.message;
}

# Raw interface to libnotify
sub notify_init(Str $appname --> int64) is native(LIB) { * }
sub notify_uninit() is native(LIB) { * }
sub notify_is_initted(--> int64) is native(LIB) { * }
sub notify_get_app_name(--> Str) is native(LIB) { * }
sub notify_set_app_name(Str $appname) is native(LIB) { * }
sub notify_notification_new(Str $summary,
                            Str $body,
                            Str $icon --> NotifyNotification)
                            is native(LIB) { * }
sub notify_notification_show(NotifyNotification $notification, GError $error is rw --> int64)
                            is native(LIB) { * }
sub notify_notification_close(NotifyNotification $notification, GError $error is rw --> int64)
                            is native(LIB) { * }
sub notify_notification_get_closed_reason(NotifyNotification $notification --> int64)
                            is native(LIB) { * }
sub notify_notification_get_type(--> uint64) is native(LIB) { * }
sub notify_notification_update(NotifyNotification $notification,
                            Str $summary,
                            Str $body,
                            Str $icon --> int64)
                            is native(LIB) { * }
sub notify_notification_set_timeout(NotifyNotification $notification, int64 $timeout)
                            is native(LIB) { * }
sub notify_notification_set_category(NotifyNotification $notification, Str $category)
                            is native(LIB) { * }
sub notify_notification_set_urgency(NotifyNotification $notification, int64 $urgency)
                            is native(LIB) { * }

# OO interface
has GError $.error is rw;
submethod BUILD(:$app-name!) { notify_init($app-name); $!error = GError.new };
submethod DESTROY { notify_uninit(); $!error.free };
method is-initted(--> Bool) { notify_is_initted.Bool }
multi method app-name(--> Str) { notify_get_app_name }
multi method app-name(Str $appname!) { notify_set_app_name($appname) }
method new-notification(Str $summary, Str $body, Str $icon --> NotifyNotification)
{
  notify_notification_new($summary, $body, $icon);
}
method show(NotifyNotification $notification!, GError $err? --> Bool)
{
  notify_notification_show($notification, $err // $!error).Bool;
}
method close(NotifyNotification $notification!, GError $err? --> Bool)
{
  notify_notification_close($notification, $err // $!error).Bool;
}
method get-type(--> Int)
{
  notify_notification_get_type();
}
method update(NotifyNotification $notification!, Str $summary, Str $body, Str $icon --> Bool)
{
  notify_notification_update($notification, $summary, $body, $icon).Bool;
}
constant NOTIFY_EXPIRES_DEFAULT is export = -1;
constant NOTIFY_EXPIRES_NEVER   is export =  0;
method set-timeout(NotifyNotification $notification!, Int $timeout!)
{
  notify_notification_set_timeout($notification, $timeout);
}
method set-category(NotifyNotification $notification!, Str $category!)
{
  notify_notification_set_category($notification, $category);
}
enum NotifyUrgency <low normal critical>;
method set-urgency(NotifyNotification $notification!, NotifyUrgency $urgency!)
{
  notify_notification_set_urgency($notification, $urgency);
}
method why-closed(NotifyNotification $notification! --> Int)
{
  notify_notification_get_closed_reason($notification);
}



=begin comment
# TODO
sub notify_get_server_info(Pointer[Str] $name,
                           Pointer[Str] $vendor,
                           Pointer[Str] $version,
                           Pointer[Str] $spec_version --> int64) is native(LIB) { * }
method server-info(--> List)
{
  my Pointer[Str] ($name, $vendor, $version, $spec_version);
  notify_get_server_info($name, $vendor, $version, $spec_version);
  return ($name, $vendor, $version, $spec_version);
}

class GList is repr('CStruct') {
  has Pointer[void] $.data;
#  has Pointer[GList] $.next;
#  has Pointer[GList] $.prev;
}
sub notify_get_server_caps(--> GList) is native(LIB) { * }

NotifyActionCallback
notify_notification_set_image_from_pixbuf
notify_notification_set_hint
notify_notification_clear_hints
notify_notification_add_action
notify_notification_clear_actions

=end comment
