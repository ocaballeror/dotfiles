# Shamelessly stolen from https://github.com/pablogsal/dotfiles.git

tm_icon="♠"
tm_color_active=colour51
tm_color_inactive=colour241
tm_color_feature=colour198
tm_color_music=colour41
tm_active_border_color=colour51

# separators
tm_separator_left_bold="◀"
tm_separator_left_thin="❮"
tm_separator_right_bold="▶"
tm_separator_right_thin="❯"

set -g status-left-length 32
set -g status-right-length 150
set -g status-interval 5


# default statusbar colors
set-option -g status-bg colour234
set-option -g status-fg $tm_color_active

# active window title colors
set-window-option -g window-status-current-style "bg=default fg=$tm_color_active"
set-window-option -g window-status-current-format "#[bold]#I #W"

# pane border
set-option -g pane-border-style fg=$tm_color_inactive
set-option -g pane-active-border-style fg=$tm_active_border_color

# message text
set-option -g message-style "bg=default fg=$tm_color_active"

# pane number display
set-option -g display-panes-active-colour $tm_color_active
set-option -g display-panes-colour $tm_color_inactive

# clock
set-window-option -g clock-mode-colour $tm_color_active

tm_date="#[fg=$tm_color_inactive] %R %d %b"
tm_host="#[fg=$tm_color_feature,bold]#h"
tm_session_name="#[fg=$tm_color_feature,bold]$tm_icon #S"

set -g status-left $tm_session_name' '
set -g status-right $tm_tunes' '$tm_date' '$tm_host

# vim: ft=tmux
