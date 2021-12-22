use v6;

unit class Desktop::Notify::Raw:ver<1.0.0>:auth<zef:FRITH>;

use NativeCall;

constant LIB = ('notify', v4);

class NotifyNotification is repr('CPointer') is export { * } # libnotify private struct
class GError is repr('CStruct') is export {
  has int32 $.domain;
  has int32 $.code;
  has Str   $.message;
}
class GList is repr('CStruct') is export {
  has Pointer[void] $.data;
  has GList $.next;
  has GList $.prev;
}

# Raw interface to libnotify
sub notify_init(Str $appname --> int32) is native(LIB) is export { * }
sub notify_uninit() is native(LIB) is export { * }
sub notify_is_initted(--> int32) is native(LIB) is export { * }
sub notify_get_app_name(--> Str) is native(LIB) is export { * }
sub notify_set_app_name(Str $appname) is native(LIB) is export { * }
sub notify_notification_new(Str $summary,
                            Str $body,
                            Str $icon --> NotifyNotification)
                            is native(LIB) is export { * }
sub notify_notification_show(NotifyNotification $notification, GError $error is rw --> int32)
                            is native(LIB) is export { * }
sub notify_notification_close(NotifyNotification $notification, GError $error is rw --> int32)
                            is native(LIB) is export { * }
sub notify_notification_get_closed_reason(NotifyNotification $notification --> int32)
                            is native(LIB) is export { * }
sub notify_notification_get_type(--> uint64) is native(LIB) is export { * }
sub notify_notification_update(NotifyNotification $notification,
                            Str $summary,
                            Str $body,
                            Str $icon --> int32)
                            is native(LIB) is export { * }
sub notify_notification_set_timeout(NotifyNotification $notification, int32 $timeout)
                            is native(LIB) is export { * }
sub notify_notification_set_category(NotifyNotification $notification, Str $category)
                            is native(LIB) is export { * }
sub notify_notification_set_urgency(NotifyNotification $notification, int32 $urgency)
                            is native(LIB) is export { * }
sub notify_get_server_caps(--> GList) is native(LIB) is export { * }
sub notify_get_server_info(Pointer[Str] $name is rw,
                           Pointer[Str] $vendor is rw,
                           Pointer[Str] $version is rw,
                           Pointer[Str] $spec_version is rw --> int32)
                           is native(LIB) is export { * }
sub notify_notification_add_action(NotifyNotification $notification2,
                                   Str $action2,
                                   Str $label,
                                   &callback (NotifyNotification $notification1, Str $action1, Pointer[void] $dummy1?),
                                   Pointer[void] $dummy2?,
                                   &free? (Pointer[void] $mem))
                                   is native(LIB) is export { * }
sub notify_notification_clear_actions(NotifyNotification $notification) is native(LIB) is export { * }
