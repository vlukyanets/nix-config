{ config, pkgs, inputs, ... }:
{
  imports =
    [
      ../../modules/home/dev/rust.nix
      ../../modules/home/dev/python.nix
    ];

  home.username = "valentinl";
  home.homeDirectory = "/home/valentinl";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Valentin Lukyanets";
        email = "valikluks95@gmail.com";
      };

      init.defaultBranch = "master";
      pull.rebase = true;
      http.postBuffer = 524288000;
    };
  };

  programs.zsh.enable = true;

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "Liberation Mono";
      font_size = 11;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      window_padding_width = 4;
      background_opacity = "0.95";
      confirm_os_window_close = 0;
    };
  };

  programs.firefox.enable = true;

  # Niri compositor configuration
  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "us,ua"
                options "grp:alt_shift_toggle"
            }
        }

        touchpad {
            tap
            natural-scroll
            accel-speed 0.3
            accel-profile "adaptive"
        }

        mouse {
            accel-speed 0.0
            accel-profile "flat"
        }
    }

    output "eDP-1" {
        scale 1.0
    }

    layout {
        gaps 8
        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        focus-ring {
            width 2
            active-color "#7fc8ff"
            inactive-color "#505050"
        }
    }

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/screenshot-%Y-%m-%d-%H-%M-%S.png"

    binds {
        // Terminal
        Mod+Return { spawn "kitty"; }

        // Application launcher
        Mod+D { spawn "fuzzel"; }

        // Browser
        Mod+B { spawn "firefox"; }

        // Screenshot
        Print { screenshot; }
        Mod+Print { screenshot-screen; }
        Mod+Shift+Print { screenshot-window; }

        // Window management
        Mod+Q { close-window; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        // Focus
        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up { focus-window-up; }
        Mod+Down { focus-window-down; }
        Mod+H { focus-column-left; }
        Mod+L { focus-column-right; }
        Mod+K { focus-window-up; }
        Mod+J { focus-window-down; }

        // Move windows
        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Up { move-window-up; }
        Mod+Shift+Down { move-window-down; }
        Mod+Shift+H { move-column-left; }
        Mod+Shift+L { move-column-right; }
        Mod+Shift+K { move-window-up; }
        Mod+Shift+J { move-window-down; }

        // Workspaces
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }

        // Column sizing
        Mod+R { switch-preset-column-width; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        // Screen lock
        Mod+Escape { spawn "swaylock"; }

        // Brightness
        XF86MonBrightnessUp { spawn "brightnessctl" "set" "+5%"; }
        XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

        // Volume
        XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

        // Power menu / session
        Mod+Shift+E { quit; }
    }
  '';

  dev.rust.enableStable = true;
  dev.python = {
    enable = true;
    libraries = [ "requests" "numpy" "scipy" "matplotlib" "pandas" ];
    enableDevTools = true;
  };
}
