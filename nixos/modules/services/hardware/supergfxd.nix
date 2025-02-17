{ config, lib, pkgs, ... }:

let
  cfg = config.services.supergfxd;
  ini = pkgs.formats.ini { };
in
{
  options = {
    services.supergfxd = {
      enable = lib.mkEnableOption (lib.mdDoc "Enable the supergfxd service");

      settings = lib.mkOption {
        type = lib.types.nullOr ini.type;
        default = null;
        description = lib.mdDoc ''
          The content of /etc/supergfxd.conf.
          See https://gitlab.com/asus-linux/supergfxctl/#config-options-etcsupergfxdconf.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.supergfxctl ];

    environment.etc."supergfxd.conf" = lib.mkIf (cfg.settings != null) (ini.generate "supergfxd.conf" cfg.settings);

    services.dbus.enable = true;

    systemd.packages = [ pkgs.supergfxctl ];
    systemd.services.supergfxd.wantedBy = [ "multi-user.target" ];

    services.dbus.packages = [ pkgs.supergfxctl ];
    services.udev.packages = [ pkgs.supergfxctl ];
  };

  meta.maintainers = pkgs.supergfxctl.meta.maintainers;
}
