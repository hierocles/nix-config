{
  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = rofi -dmenu -i -theme gruvbox-dark-soft
    format = {name}  {sec}
    list_saved = true
    highlight = true

    [dmenu_passphrase]
    obscure = true
    obscure_color = #282828

    [pinentry]
    description = "Enter password for network"
    prompt = "Password:"

    [editor]
    terminal = kitty nvim
  '';
}
