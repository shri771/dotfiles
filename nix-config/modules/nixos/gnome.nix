{ ... }:
{
  # GDM greeter (replaces SDDM)
  services.displayManager.gdm.enable = true;

  # GNOME desktop (selectable at login; Hyprland stays the default session)
  services.desktopManager.gnome.enable = true;

  # Strip out GNOME's default app suite — keep just the shell
  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
}
