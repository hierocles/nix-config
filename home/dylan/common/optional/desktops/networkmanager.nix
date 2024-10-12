{
  xdg.configFile."networkmanager-dmenu/config.ini".source = ''
    [dmenu]
    dmenu_command = rofi -dmenu -i -theme nmdm
    active_chars = ==
    format = {name}  {sec}  {bars}
    list_saved = true

    [editor]
    terminal = kitty nvim
  '';
}
