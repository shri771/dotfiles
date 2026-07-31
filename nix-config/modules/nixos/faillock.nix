# Lock accounts after repeated failed password attempts (pam_faillock).
# Applies to console login, sudo, su, ssh and the GDM greeter. Root included.
{ config, pkgs, lib, ... }:
let
  # Services whose PAM stack should enforce lockout.
  # NOTE: gdm-password is intentionally excluded — it's a stub that delegates
  # to the `login` stack (its only rule is `login`, it has no `unix` to anchor
  # against), so GDM logins are already covered transitively via `login`.
  services = [
    "login"
    "sudo"
    "su"
    "sshd"
  ];

  faillock = "${pkgs.pam}/lib/security/pam_faillock.so";

  # Wire pam_faillock into one service's auth + account stack, ordered
  # relative to that service's own pam_unix rule (never hard-coded).
  mkFaillock = svc: {
    # Deny already-locked users BEFORE pam_unix (which is `sufficient`).
    rules.auth.faillock_preauth = {
      order = config.security.pam.services.${svc}.rules.auth.unix.order - 100;
      control = "required";
      modulePath = faillock;
      settings = {
        preauth = true;
        silent = true;
      };
    };
    # Record a failure AFTER pam_unix rejects the password.
    rules.auth.faillock_authfail = {
      order = config.security.pam.services.${svc}.rules.auth.unix.order + 100;
      control = "[default=die]";
      modulePath = faillock;
      settings.authfail = true;
    };
    # Clear the tally on a successful login.
    rules.account.faillock = {
      order = config.security.pam.services.${svc}.rules.account.unix.order - 100;
      control = "required";
      modulePath = faillock;
    };
  };
in
{
  # Tunables read by every pam_faillock invocation.
  environment.etc."security/faillock.conf".text = ''
    deny = 5
    fail_interval = 900
    unlock_time = 900
    even_deny_root
    root_unlock_time = 900
  '';

  security.pam.services = lib.genAttrs services mkFaillock;
}
