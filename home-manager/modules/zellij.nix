{ pkgs, config, isServer, ... }: {
  programs = {
    zellij = {
      enable = true;
      enableFishIntegration = true;
      exitShellOnExit = true;
      attachExistingSession = true;
    };
    fish = {
      # force the function to load so it starts watching PWD
      shellInitLast = "_update_zellij_tab_name";
      functions."_update_zellij_tab_name" = {
        onEvent = "fish_prompt";
        onVariable = "PWD";
        body = ''
          if string match -q "$HOME/git/*" "$PWD" || string match -q "$HOME/go/*" "$PWD"
              if test -d .git; or git rev-parse --git-dir > /dev/null 2>&1
                set -l repo_name (basename $PWD)
                set -l current_branch (git branch --show-current)

                if test -n current_branch
                    set current_branch ":$current_branch"
                end

                set -l tab_title "$repo_name$current_branch"
                if test -n "$ZELLIJ"
                    command nohup zellij action rename-tab "$tab_title" >/dev/null 2>&1
                end
              end
          end
        '';
      };
    };
  };

  xdg.configFile = {
    "zellij/config.kdl".text = ''
      theme "tokyo-night-dark"
      pane_frames false
      copy_on_select true
      scroll_buffer_size 10000
      show_startup_tips false
      ui {
          pane_frames {
              rounded_corners true
              hide_session_name true
          }
      }
      keybinds clear-defaults=true {
          normal {
              bind "Super p" {
                  LaunchOrFocusPlugin "plugin-manager" {
                      floating true
                      move_to_focused_tab true
                  };
              }

              bind "Ctrl b" { SwitchToMode "tmux"; }

              bind "Super t" { ToggleFloatingPanes; }

              bind "Alt n" {
                  NewTab {
                      cwd "${config.home.homeDirectory}"
                  }
              }
              bind "Super r" { SwitchToMode "RenameTab"; TabNameInput 0; }
              bind "Alt Left" { GoToPreviousTab; }
              bind "Alt Right" { GoToNextTab; }
          }

          tmux {
              bind "\\" { NewPane "Right"; SwitchToMode "normal"; }
              bind "-" { NewPane "Down"; SwitchToMode "normal"; }
              bind "Esc" { SwitchToMode "normal"; }

              bind "e" { EditScrollback; }
          }

          renametab {
              bind "Esc" { SwitchToMode "Normal"; }
              bind "Enter" { SwitchToMode "Normal"; }
          }

          shared_except "locked" {
              bind "Ctrl h" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "move_focus";
                      payload "left";
                  };
              }
              bind "Ctrl j" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "move_focus";
                      payload "down";
                  };
              }
              bind "Ctrl k" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "move_focus";
                      payload "up";
                  };
              }
              bind "Ctrl l" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "move_focus";
                      payload "right";
                  };
              }
              bind "Alt h" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "resize";
                      payload "left";
                  };
              }
              bind "Alt j" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "resize";
                      payload "down";
                  };
              }
              bind "Alt k" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "resize";
                      payload "up";
                  };
              }
              bind "Alt l" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "resize";
                      payload "right";
                  };
              }
          }
      }
      load_plugins {
        "file:${pkgs.zjstatus}/bin/zjframes.wasm" {
          hide_frame_except_for_search     "true"
          hide_frame_except_for_scroll     "true"
          hide_frame_except_for_fullscreen "true"
        }
      }
    '';
    "zellij/layouts/default.kdl".text = ''
      layout {
        default_tab_template {
          children
          pane size=1 borderless=true {
              plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                  color_bg_dark "#1a1b26"
                  color_bg "#24283b"
                  color_bg_highlight "#292e42"
                  color_terminal_black "#414868"
                  color_fg "#c0caf5"
                  color_fg_dark "#a9b1d6"
                  color_fg_gutter "#3b4261"
                  color_dark3 "#545c7e"
                  color_comment "#565f89"
                  color_dark5 "#737aa2"
                  color_blue0 "#3d59a1"
                  color_blue "#7aa2f7"
                  color_cyan "#7dcfff"
                  color_blue1 "#2ac3de"
                  color_blue2 "#0db9d7"
                  color_blue5 "#89ddff"
                  color_blue6 "#b4f9f8"
                  color_blue7 "#394b70"
                  color_magenta "#bb9af7"
                  color_magenta2 "#ff007c"
                  color_purple "#9d7cd8"
                  color_orange "#ff9e64"
                  color_yellow "#e0af68"
                  color_green "#9ece6a"
                  color_green1 "#73daca"
                  color_green2 "#41a6b5"
                  color_teal "#1abc9c"
                  color_red "#f7768e"
                  color_red1 "#db4b4b"

                  format_left   "#[bg=$bg]{tabs}"
                  format_center "{notifications}"
                  format_right  "{mode}${
                    if isServer then "  mat@nixos-server" else ""
                  }#[bg=$bg]"
                  format_space  "#[bg=$bg]"
                  format_hide_on_overlength "true"
                  format_precedence "lrc"

                  border_enabled  "false"
                  border_char     "─"
                  border_format   "#[bg=$bg]{char}"
                  border_position "top"

                  mode_normal        "#[bg=$green,fg=$bg,bold]   #[bg=$bg,fg=$green]"
                  mode_tmux          "#[bg=$purple,fg=$bg,bold]   #[bg=$bg,fg=$purple]"
                  mode_locked        "#[bg=$red,fg=$bg,bold]    #[bg=$bg,fg=$red]"
                  mode_pane          "#[bg=$cyan,fg=$bg,bold]   #[bg=$bg,fg=$cyan]"
                  mode_tab           "#[bg=$cyan,fg=$bg,bold] 󰓩  #[bg=$bg,fg=$cyan]"
                  mode_scroll        "#[bg=$orange,fg=$bg,bold] 󱕒  #[bg=$bg,fg=$orange]"
                  mode_enter_search  "#[bg=$orange,fg=$bg,bold]   #[bg=$bg,fg=$orange]"
                  mode_search        "#[bg=$orange,fg=$bg,bold]   #[bg=$bg,fg=$orange]"
                  mode_resize        "#[bg=$yellow,fg=$bg,bold] 󰙖  #[bg=$bg,fg=$yellow]"
                  mode_rename_tab    "#[bg=$yellow,fg=$bg,bold]    #[bg=$bg,fg=$yellow]"
                  mode_rename_pane   "#[bg=$yellow,fg=$bg,bold]    #[bg=$bg,fg=$yellow]"
                  mode_move          "#[bg=$yellow,fg=$bg,bold]   #[bg=$bg,fg=$yellow]"
                  mode_session       "#[bg=$magenta,fg=$bg,bold]   #[bg=$bg,fg=$magenta]"
                  mode_prompt        "#[bg=$magenta,fg=$bg,bold] 󰟶  #[bg=$bg,fg=$magenta]"

                  tab_normal              "#[bg=$terminal_black,fg=$fg_dark,bold] {index} {name}{floating_indicator} #[bg=$bg,fg=$comment]"
                  tab_normal_fullscreen   "#[bg=$terminal_black,fg=$fg_dark,bold] {index} {name}{fullscreen_indicator} #[bg=$bg,fg=$comment]"
                  tab_normal_sync         "#[bg=$terminal_black,fg=$fg_dark,bold] {index} {name}{sync_indicator} #[bg=$bg,fg=$comment]"
                  tab_active              "#[bg=$bg_dark,fg=$blue,bold] {index} {name}{floating_indicator} #[bg=$bg,fg=$comment]"
                  tab_active_fullscreen   "#[bg=$bg_dark,fg=$blue,bold] {index} {name}{fullscreen_indicator} #[bg=$bg,fg=$comment]"
                  tab_active_sync         "#[bg=$bg_dark,fg=$blue,bold] {index} {name}{sync_indicator} #[bg=$bg,fg=$comment]"
                  tab_separator           "#[bg=$bg] "

                  tab_sync_indicator       " "
                  tab_fullscreen_indicator " 󰊓 "
                  tab_floating_indicator   " 󰹙 "

                  notification_format_unread "#[bg=$bg,fg=$yellow]#[bg=$yellow,fg=$bg_dark] #[bg=$bg_highlight,fg=$yellow] {message}#[bg=$bg,fg=$yellow]"
                  notification_format_no_notifications ""
                  notification_show_interval "10"
              }
          }
        }
      }
    '';
    "zellij/layouts/ssh.kdl".text = ''
      layout {
        pane command="ssh" {
            args "mat@nixos-server"
        }
      }
      default_mode "locked"
    '';
  };

}
