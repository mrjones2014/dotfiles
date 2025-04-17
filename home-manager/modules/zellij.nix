{ pkgs, lib, config, isServer, ... }:
with import ./tokyonight_palette.nix;
{
  programs = {
    zellij = {
      enable = true;
      enableFishIntegration = true;
      exitShellOnExit = true;
      attachExistingSession = true;
    };
    fish = lib.mkIf config.programs.starship.enable {
      # force the function to load so it starts watching PWD
      interactiveShellInit = "_update_zellij_tab_name";
      functions."_update_zellij_tab_name" = {
        onEvent = "fish_prompt";
        onVariable = "PWD";
        body = ''
          set -l branch (string trim $(git branch --show-current 2> /dev/null))
          set -l cwd (pwd)
          if test "$branch" != ""
            # just show basename if inside branch
            set cwd (basename "$cwd")
          else
            # otherwise, replace $HOME with ~ and truncate if needed
            set cwd (string replace "$HOME" "~" "$cwd")
            if test (string length "$cwd") -gt 30
                set -l parts (string split / "$cwd")
                set -l first (string join / $parts[1])
                set -l last (string join / $parts[-1])
                set cwd "$first/…/$last"
            end
          end
          set -l title "$cwd"
          if test "$branch" != ""
            set title "$title:$branch"
          end
          command nohup zellij action rename-tab "$title" >/dev/null 2>&1
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
                      name "~"
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
          pane {
            cwd "${config.home.homeDirectory}"
          }
          pane size=1 borderless=true {
              plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                  format_left   "#[bg=${bg}]{tabs}"
                  format_center "{notifications}"
                  format_right  "{mode}${
                    if isServer then "#[bg=${green},fg=${bg}]  mat@nixos-server " else ""
                  }#[bg=${bg}]"
                  format_space  "#[bg=${bg}]"
                  format_hide_on_overlength "true"
                  format_precedence "lrc"

                  border_enabled  "false"
                  border_char     "─"
                  border_format   "#[bg=${bg}]{char}"
                  border_position "top"

                  mode_normal        "#[bg=${green},fg=${bg},bold]   #[bg=${bg},fg=${green}]"
                  mode_tmux          "#[bg=${purple},fg=${bg},bold]   #[bg=${bg},fg=${purple}]"
                  mode_locked        "#[bg=${red},fg=${bg},bold]    #[bg=${bg},fg=${red}]"
                  mode_pane          "#[bg=${cyan},fg=${bg},bold]   #[bg=${bg},fg=${cyan}]"
                  mode_tab           "#[bg=${cyan},fg=${bg},bold] 󰓩  #[bg=${bg},fg=${cyan}]"
                  mode_scroll        "#[bg=${orange},fg=${bg},bold] 󱕒  #[bg=${bg},fg=${orange}]"
                  mode_enter_search  "#[bg=${orange},fg=${bg},bold]   #[bg=${bg},fg=${orange}]"
                  mode_search        "#[bg=${orange},fg=${bg},bold]   #[bg=${bg},fg=${orange}]"
                  mode_resize        "#[bg=${yellow},fg=${bg},bold] 󰙖  #[bg=${bg},fg=${yellow}]"
                  mode_rename_tab    "#[bg=${yellow},fg=${bg},bold]    #[bg=${bg},fg=${yellow}]"
                  mode_rename_pane   "#[bg=${yellow},fg=${bg},bold]    #[bg=${bg},fg=${yellow}]"
                  mode_move          "#[bg=${yellow},fg=${bg},bold]   #[bg=${bg},fg=${yellow}]"
                  mode_session       "#[bg=${magenta},fg=${bg},bold]   #[bg=${bg},fg=${magenta}]"
                  mode_prompt        "#[bg=${magenta},fg=${bg},bold] 󰟶  #[bg=${bg},fg=${magenta}]"

                  tab_normal              "#[bg=${terminal_black},fg=${fg_dark},bold] {index} {name}{floating_indicator} #[bg=${bg},fg=${comment}]"
                  tab_normal_fullscreen   "#[bg=${terminal_black},fg=${fg_dark},bold] {index} {name}{fullscreen_indicator} #[bg=${bg},fg=${comment}]"
                  tab_normal_sync         "#[bg=${terminal_black},fg=${fg_dark},bold] {index} {name}{sync_indicator} #[bg=${bg},fg=${comment}]"
                  tab_active              "#[bg=${bg_dark},fg=${blue},bold] {index} {name}{floating_indicator} #[bg=${bg},fg=${comment}]"
                  tab_active_fullscreen   "#[bg=${bg_dark},fg=${blue},bold] {index} {name}{fullscreen_indicator} #[bg=${bg},fg=${comment}]"
                  tab_active_sync         "#[bg=${bg_dark},fg=${blue},bold] {index} {name}{sync_indicator} #[bg=${bg},fg=${comment}]"
                  tab_separator           "#[bg=${bg}] "

                  tab_sync_indicator       " "
                  tab_fullscreen_indicator " 󰊓 "
                  tab_floating_indicator   " 󰹙 "

                  notification_format_unread "#[bg=${bg},fg=${yellow}]#[bg=${yellow},fg=${bg_dark}] #[bg=${bg_highlight},fg=${yellow}] {message}#[bg=${bg},fg=${yellow}]"
                  notification_format_no_notifications ""
                  notification_show_interval "10"
              }
          }
        }
      }
    '';
  };
}
