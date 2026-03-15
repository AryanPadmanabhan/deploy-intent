{ self, pkgs, ... }:
{
  imports = [ ];

  system.stateVersion = "25.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "ota-vm";
  networking.useNetworkd = true;
  systemd.network.enable = true;

  environment.systemPackages = [ pkgs.tree ];
  environment.etc."deploy-intent/baseline-release".text = "baseline";

  services.openssh.enable = true;

  services.deploy-intent-agent = {
    enable = true;
    package = self.packages.${pkgs.system}.deploy-intent;
    serverUrl = "http://10.2.24.81:8080";
    assetId = "ota-vm";
    assetType = "edge-linux-aarch64";
    missionState = "idle";
    pollSeconds = 15;
    stateDir = "/var/lib/deploy-intent";
    labels = [ "region=lab" ];
  };
}
