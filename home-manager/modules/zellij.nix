{ pkgs, ... }: {
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
  };
  xdg.configFile."zellij/config.kdl".text = ''
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

            bind "Ctrl b" { SwitchToMode "pane"; }

            // Toggle floating terminal with Super+t
            bind "Super t" { ToggleFloatingPanes; }

            // Tab management
            bind "Alt n" { NewTab; }
            bind "Super r" { SwitchToMode "RenameTab"; TabNameInput 0; }
            bind "Alt Left" { GoToPreviousTab; }
            bind "Alt Right" { GoToNextTab; }
        }

        pane {
            bind "\\" { NewPane "Right"; SwitchToMode "normal"; }
            bind "-" { NewPane "Down"; SwitchToMode "normal"; }
            bind "Esc" { SwitchToMode "normal"; }
        }

        // Minimal mode for tab renaming
        renametab {
            bind "Esc" { SwitchToMode "Normal"; }
            bind "Enter" { SwitchToMode "Normal"; }
        }

        shared_except "locked" {
            bind "Ctrl h" {
                MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                    name "move_focus_or_tab";
                    payload "left";
                    move_mod "ctrl";
                    resize_mod "alt";
                };
            }
            bind "Ctrl j" {
                MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                    name "move_focus";
                    payload "down";
                    move_mod "ctrl";
                    resize_mod "alt";
                };
            }
            bind "Ctrl k" {
                MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                    name "move_focus";
                    payload "up";
                    move_mod "ctrl";
                    resize_mod "alt";
                };
            }
            bind "Ctrl l" {
                MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                    name "move_focus_or_tab";
                    payload "right";
                    move_mod "ctrl";
                    resize_mod "alt";
                };
            }
            bind "Alt h" {
                MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                    name "resize";
                    payload "left";
                    move_mod "ctrl";
                    resize_mod "alt";
                };
            }
            bind "Alt j" {
                MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                    name "resize";
                    payload "down";
                    move_mod "ctrl";
                    resize_mod "alt";
                };
            }
            bind "Alt k" {
                MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                    name "resize";
                    payload "up";
                    move_mod "ctrl";
                    resize_mod "alt";
                };
            }
            bind "Alt l" {
                MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                    name "resize";
                    payload "right";
                    move_mod "ctrl";
                    resize_mod "alt";
                };
            }
        }
    }
  '';
  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
      default_tab_template {
        pane size=1 borderless=true {
              plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                // -- Tokyo Night Colors --
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

                // Updated format with mode moved to right and session removed
                format_left   "#[bg=$bg_dark]{notifications}"
                format_center "{tabs}"
                format_right  "{mode}#[bg=$bg_dark]"
                format_space  "#[bg=$bg_dark]"
                format_hide_on_overlength "true"
                format_precedence "lrc"

                border_enabled  "false"
                border_char     "─"
                border_format   "#[bg=$bg]{char}"
                border_position "top"

                hide_frame_for_single_pane "true"

                // Updated mode indicators with Tokyo Night colors
                mode_normal        "#[fg=$green,bg=$bg_dark,bold]#[bg=$green,fg=$bg_dark,bold] NORMAL #[bg=$bg,fg=$green]"
                mode_tmux          "#[fg=$purple,bg=$bg_dark,bold]#[bg=$purple,fg=$bg_dark,bold] TMUX #[bg=$bg,fg=$purple]"
                mode_locked        "#[fg=$red,bg=$bg_dark,bold]#[bg=$red,fg=$bg_dark,bold] LOCKED #[bg=$bg,fg=$red]"
                mode_pane          "#[fg=$cyan,bg=$bg_dark,bold]#[bg=$cyan,fg=$bg_dark,bold] PANE #[bg=$bg,fg=$cyan]"
                mode_tab           "#[fg=$cyan,bg=$bg_dark,bold]#[bg=$cyan,fg=$bg_dark,bold] TAB #[bg=$bg,fg=$cyan]"
                mode_scroll        "#[fg=$orange,bg=$bg_dark,bold]#[bg=$orange,fg=$bg_dark,bold] SCROLL #[bg=$bg,fg=$orange]"
                mode_enter_search  "#[fg=$orange,bg=$bg_dark,bold]#[bg=$orange,fg=$bg_dark,bold] ENT-SEARCH #[bg=$bg,fg=$orange]"
                mode_search        "#[fg=$orange,bg=$bg_dark,bold]#[bg=$orange,fg=$bg_dark,bold] SEARCH #[bg=$bg,fg=$orange]"
                mode_resize        "#[fg=$yellow,bg=$bg_dark,bold]#[bg=$yellow,fg=$bg_dark,bold] RESIZE #[bg=$bg,fg=$yellow]"
                mode_rename_tab    "#[fg=$yellow,bg=$bg_dark,bold]#[bg=$yellow,fg=$bg_dark,bold] RENAME-TAB #[bg=$bg,fg=$yellow]"
                mode_rename_pane   "#[fg=$yellow,bg=$bg_dark,bold]#[bg=$yellow,fg=$bg_dark,bold] RENAME-PANE #[bg=$bg,fg=$yellow]"
                mode_move          "#[fg=$yellow,bg=$bg_dark,bold]#[bg=$yellow,fg=$bg_dark,bold] MOVE #[bg=$bg,fg=$yellow]"
                mode_session       "#[fg=$magenta,bg=$bg_dark,bold]#[bg=$magenta,fg=$bg_dark,bold] SESSION #[bg=$bg,fg=$magenta]"
                mode_prompt        "#[fg=$magenta,bg=$bg_dark,bold]#[bg=$magenta,fg=$bg_dark,bold] PROMPT #[bg=$bg,fg=$magenta]"

                // Updated tab styling with green for active tabs
                tab_normal              "#[bg=$bg,fg=$blue]#[bg=$bg_dark,fg=$blue,bold]#[bg=$blue,fg=$bg_dark,bold]{index} #[bg=$bg_highlight,fg=$blue,bold] {name}{floating_indicator}#[bg=$bg_dark,fg=$bg_highlight]#[bg=$bg_dark,fg=$bg_highlight]"
                tab_normal_fullscreen   "#[bg=$bg,fg=$blue]#[bg=$bg_dark,fg=$blue,bold]#[bg=$blue,fg=$bg_dark,bold]{index} #[bg=$bg_highlight,fg=$blue,bold] {name}{fullscreen_indicator}#[bg=$bg_dark,fg=$bg_highlight]#[bg=$bg_dark,fg=$bg_highlight]"
                tab_normal_sync         "#[bg=$bg,fg=$blue]#[bg=$bg_dark,fg=$blue,bold]#[bg=$blue,fg=$bg_dark,bold]{index} #[bg=$bg_highlight,fg=$blue,bold] {name}{sync_indicator}#[bg=$bg_dark,fg=$bg_highlight]#[bg=$bg_dark,fg=$bg_highlight]"
                tab_active              "#[bg=$bg,fg=$green]#[bg=$bg_dark,fg=$green,bold]#[bg=$green,fg=$bg_dark,bold]{index} #[bg=$bg_highlight,fg=$green,bold] {name}{floating_indicator}#[bg=$bg_dark,fg=$bg_highlight]#[bg=$bg_dark,fg=$bg_highlight]"
                tab_active_fullscreen   "#[bg=$bg,fg=$green]#[bg=$bg_dark,fg=$green,bold]#[bg=$green,fg=$bg_dark,bold]{index} #[bg=$bg_highlight,fg=$green,bold] {name}{fullscreen_indicator}#[bg=$bg_dark,fg=$bg_highlight]#[bg=$bg_dark,fg=$bg_highlight]"
                tab_active_sync         "#[bg=$bg,fg=$green]#[bg=$bg_dark,fg=$green,bold]#[bg=$green,fg=$bg_dark,bold]{index} #[bg=$bg_highlight,fg=$green,bold] {name}{sync_indicator}#[bg=$bg_dark,fg=$bg_highlight]#[bg=$bg_dark,fg=$bg_highlight]"
                tab_separator           "#[bg=$bg_dark] "

                tab_sync_indicator       " "
                tab_fullscreen_indicator " 󰊓"
                tab_floating_indicator   " 󰹙"

                notification_format_unread "#[bg=$bg,fg=$yellow]#[bg=$yellow,fg=$bg_dark] #[bg=$bg_highlight,fg=$yellow] {message}#[bg=$bg,fg=$yellow]"
                notification_format_no_notifications ""
                notification_show_interval "10"
            }
        }
        children
      }
    }
  '';
}
