{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.bacon;

  settingsFormat = pkgs.formats.toml { };

  configDir = if pkgs.stdenv.isDarwin then
    "Library/Application Support/org.dystroy.bacon"
  else
    "${config.xdg.configHome}/bacon";

in {
  meta.maintainers = [ hm.maintainers.shimunn ];

  options.programs.bacon = {
    enable = mkEnableOption "bacon, a background rust code checker";

    package = mkPackageOption pkgs "bacon" { nullable = true; };

    settings = mkOption {
      type = settingsFormat.type;
      default = { };
      example = {
        jobs.default = {
          command = [ "cargo" "build" "--all-features" "--color" "always" ];
          need_stdout = true;
        };
      };
      description = ''
        Bacon configuration.
        For available settings see <https://dystroy.org/bacon/#global-preferences>.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    home.file."${configDir}/prefs.toml" = mkIf (cfg.settings != { }) {
      source = settingsFormat.generate "prefs.toml" cfg.settings;
    };
  };
}
