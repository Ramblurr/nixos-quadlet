{
  config,
  options,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.virtualisation.user.quadlet;
  quadletUtils = import ./utils.nix {
    inherit lib;
    systemdLib = lib.systemdLib { inherit lib config pkgs; };
  };
  # TODO: replace with lib.mergeAttrsList once stable.
  mergeAttrsList = lib.foldl lib.mergeAttrs { };

  containerOpts = lib.types.submodule (import ./container.nix { inherit quadletUtils; });
  networkOpts = lib.types.submodule (import ./network.nix { inherit quadletUtils pkgs; });
in
{
  options.virtualisation.user.quadlet = { };

  config =

    let
      allObjects = (lib.attrValues cfg.containers) ++ (lib.attrValues cfg.networks);
      allUserObjects = (lib.attrValues cfg.user.containers) ++ (lib.attrValues cfg.user.networks);
    in
    {
      home.file = mergeAttrsList (
        map (p: {
          "${config.xdg.configHome}/containers/systemd/${p._configName}" = {
            text = p._configText;
            mode = "0600";
          };
        }) allObjects
      );
    };
}
