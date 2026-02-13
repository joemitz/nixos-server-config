{ pkgs, claude-code, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.joemitz = {
    home.stateVersion = "25.11";
    home.packages = [
      claude-code.packages.x86_64-linux.default
      pkgs.gh
      pkgs.jq
      pkgs.nixd
    ];

    # Git configuration
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        user = {
          name = "Joe Mitzman";
          email = "joemitz@gmail.com";
        };
        init.defaultBranch = "main";
        color.ui = "auto";
        core = {
          editor = "nano";
          autocrlf = "input";
          safecrlf = true;
          hooksPath = "/dev/null";
        };
        push.autoSetupRemote = true;
        credential."https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
        alias = {
          co = "commit -m";
          st = "status";
          br = "branch";
          hi = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
          type = "cat-file -t";
          dump = "cat-file -p";
          pu = "push";
          ad = "add";
          ch = "checkout";
          cp = "!f() { git commit -m \"$1\" && git push; }; f";
        };
      };
    };

    # Tmux configuration
    programs.tmux = {
      enable = true;
      clock24 = true;
      historyLimit = 10000;
      mouse = true;
      extraConfig = ''
        # Mouse wheel scroll
        bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
        bind -n WheelDownPane select-pane -t= \; send-keys -M

        # Custom keybindings
        bind h split-window -h    # Split horizontal with h
        bind v split-window -v    # Split vertical with v
        bind n new-window         # New window with n
        bind w kill-window        # Close window with w
        bind x kill-pane          # Close pane with x

        # Pane movement with arrow keys
        bind Right swap-pane -U   # Move pane left
        bind Up swap-pane -U      # Move pane up
        bind Down swap-pane -D    # Move pane down
        bind Left swap-pane -D    # Move pane right

        # Clear console with Ctrl+K
        bind -n C-k send-keys 'clear' Enter

        # Map Ctrl-_ to ESC [ Z (Shift-Tab)
        unbind -n C-_
        bind -n C-_ send-keys Escape '[' 'Z'

        # Enable status bar
        set -g status on
        set -g status-left "[#S] "
        set -g status-right ""
      '';
    };
  };
}
