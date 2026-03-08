{ pkgs, ... }:

{
  users.users.tst = {
    isNormalUser = true;
    description = "Tst Desktop";
    extraGroups = [ "networkmanager" "wheel" "docker" "kvm" "wireshark" "i2c" "video" "audio" ];
    initialPassword = "as";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPchxx8m1n/DJ2qGd5egSbEET7RvhKhG5p1jBhrb7o4GYYqmQLIRS9NEA3DybcNl5wKcbx1ROveHN7RhX29f3Me2DQRtcsmFfcEaOlULgeMY03dqJ596u5DvMw3dwclgGnCF2aybiDh2b+51DJeNevvIl3RzKbnnIpWhfX7hnK2Z0llk1A80v6+jV2PJJcUTGOhoetsTNuceUDs2b5HSs/m55htq1txu7h9imapMcEruVskg5t2glVKWvBUFRk+p0DQRU8iasD/exkmSQHCCicvmCYOjQqPPAOB61CSfPbIJvc4VZDKCRRgty5RkROVpAAhxrRU+MzVxb153ww+h8L shrikantshingare77@gmail.com"
    ];

    shell = pkgs.fish;
    packages = with pkgs; [
      gitFull
      gnome-keyring
      seahorse
      libsecret
      neovim
      trash-cli
      curl
      fish
      starship
      brave
      vivaldi
      jq
      zoxide
      eza
      kitty
      carapace
      fzf
      home-manager
      unzip
      tmux
      evremap
      awesome
      hyprland
      polkit
      kdePackages.kate
      noto-fonts
      noto-fonts-color-emoji
      openrgb-with-all-plugins
    ];
  };

  # Define the guest user (with the same permissions but fewer pkgs)
  users.users.guest = {
    isNormalUser = true;
    description = "Guest User";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "audio" ];
    initialPassword = "guest"; # Change this after first login
    shell = pkgs.fish;
    packages = with pkgs; [
      firefox
      git
      curl
      kitty
    ];
  };
}
