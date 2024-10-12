{config, ...}: {
  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = rofi -dmenu -i -theme ${config.xdg.configHome}/rofi/themes/gruvbox/gruvbox.rasi
    active_chars = ==
    format = {name}  {sec}  {bars}
    list_saved = true

    [editor]
    terminal = kitty nvim
  '';
}
