{ config, lib, pkgs, ... }:

let sources = import ../../nix/sources.nix; in {
  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = with pkgs; [
    go
    gopls
    tree
    watch
  ];

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "vim";
    PAGER = "less -FirSwX";
    MANPAGER = "less -FirSwX";
  };

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.git = {
    enable = true;
    userName = "Michael Shen";
    userEmail = "mshen@redhat.com";
    signing = {
      key = "9E6D30416ED221971E62803112CC712F576BDFEE";
      signByDefault = true;
    };
    extraConfig = {
      color.ui = true;
      init.defaultBranch = "main";
    };
  };

  programs.gpg.enable = true;

  programs.jq.enable = true;

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";

    extraConfig = (builtins.readFile ./tmux.conf);
  };

  programs.vim = {
    enable = true;

    extraConfig = (builtins.readFile ./vimrc);
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "sindresorhus";
          repo = "pure";
          rev = "v1.18.0";
          sha256 = "sha256-nsmiP1RSG27WtwRJpTZvDi2CvUQExxdBs5my7T5TSKk=";
        };
      }
    ];
  };

  #---------------------------------------------------------------------
  # Services
  #---------------------------------------------------------------------

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";
  };
}
