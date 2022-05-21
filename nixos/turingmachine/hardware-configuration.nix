# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
  ];

  # on demand
  services.fwupd.enable = false;

  # xps
  #boot.initrd.availableKernelModules = [
  #  "xhci_pci"
  #  "ehci_pci"
  #  # required on thinkpad
  #  #"ahci"
  #  "usb_storage"
  #  "sd_mod"
  #  "rtsx_pci_sdmmc"
  #  "nvme"
  #];
  # x13
  #boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "sdhci_pci"];
  # framework
  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "thunderbolt"];
  boot.kernelModules = ["kvm-intel"];

  # for zfs
  networking.hostId = "8425e349";

  hardware = {
    bluetooth.enable = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
    #pulseaudio = {
    #  enable = true;
    #  package = pkgs.pulseaudioFull;
    #};
  };

  # for pactl
  environment.systemPackages = with pkgs; [pulseaudio];

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/SYSTEM";
    fsType = "vfat";
    options = ["nofail"];
  };

  fileSystems."/" = {
    device = "zroot/root/nixos";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/home" = {
    device = "zroot/root/home";
    fsType = "zfs";
    options = ["nofail" "zfsutil"];
  };

  fileSystems."/home/joerg/Musik/podcasts" = {
    device = "/home/joerg/gPodder/Downloads";
    fsType = "none";
    options = ["bind" "nofail"];
  };

  fileSystems."/tmp" = {
    device = "zroot/root/tmp";
    fsType = "zfs";
    options = ["nofail" "zfsutil"];
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.video.hidpi.enable = lib.mkDefault true;
}
