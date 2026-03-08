{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Shrikant Shingare";
    userEmail = "shrikantshingare77@gmail.com";

    # This single line handles all your filter.lfs.* settings automatically!
    lfs.enable = true;

    signing = {
      key = "shrikantshingare77@gmail.com";
      signByDefault = true;
    };

    extraConfig = {
      init = { defaultBranch = "master"; };
      pull = { rebase = true; };

      # Git diff tool settings
      diff = { tool = "nvim"; };
      difftool.nvim = { cmd = "nvim -d"; };

      # Credentials
      credential = { helper = "libsecret"; };

      # UI Colors
      color = {
        ui = "auto";
        diff = "auto";
        status = "auto";
        branch = "auto";
        log = "auto";
      };

      "color \"status\"" = {
        added = "#50fa7b";
        changed = "#f1fa8c";
        untracked = "#ff5555";
        branch = "#8be9fd";
      };

      "color \"diff\"" = {
        meta = "#bd93f9";
        frag = "#ff79c6";
        old = "#ff5555 bold";
        new = "#50fa7b bold";
        whitespace = "#ff5555 reverse";
      };

      "color \"branch\"" = {
        local = "#8be9fd";
        remote = "#ff79c6";
      };
    };
  };
}
