{lib, ...}: {
  options.modules.authelia = {
    enable = lib.mkEnableOption "authelia";
    description = "Enable the Authelia service";
  };
}
