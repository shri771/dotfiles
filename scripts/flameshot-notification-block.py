#!/usr/bin/env python3

import dbus
import dbus.mainloop.glib
from gi.repository import GLib

def filter_notification(bus, message):
    """
    Callback to filter notifications and block those containing 'Flameshot'.
    """
    # Check if the message is a method call for notifications
    if message.get_member() != "Notify":
        return
    
    args = message.get_args_list()
    
    # Notification format: [app_name, replace_id, app_icon, summary, body, actions, hints, expire_timeout]
    app_name = args[0] if len(args) > 0 else ""
    summary = args[3] if len(args) > 3 else ""
    
    # Block notifications containing "Flameshot" in app name or summary
    if "flameshot" in app_name.lower() or "flameshot" in summary.lower():
        print(f"Blocked notification: {summary}")
        return None  # Block notification
    
    return message  # Allow notification

def main():
    """
    Main method to set up the dbus notification filter.
    """
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    
    # Connect to the session bus
    bus = dbus.SessionBus()
    
    # Get the notification service
    bus.add_match_string("type='method_call',interface='org.freedesktop.Notifications'")
    bus.add_message_filter(filter_notification)
    
    # Run the main loop
    print("Blocking notifications containing 'Flameshot'...")
    loop = GLib.MainLoop()
    loop.run()

if __name__ == "__main__":
    main()


