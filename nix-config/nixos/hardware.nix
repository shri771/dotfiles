# hardware.nix — machine-specific hardware settings
#
# NOTE: fileSystems, swapDevices, and LUKS devices are NOT defined here.
# They are managed by disko via disk-config.nix.
#
# The original hardware-configuration.nix is kept in the repo for reference.
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-mod" ];   # Required for LVM in initrd
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
