{ config, lib, pkgs, ... }:

let
  completor = pkgs.vimUtils.buildVimPlugin {
    name = "completor";
    # https://github.com/NixOS/nix/issues/1880#issuecomment-953678160
    src = pkgs.fetchFromGitHub {
      owner = "maralla";
      repo = "completor.vim";
      rev = "6ca5f498afe5fe9c659751aef54ef7f2fdc62414";
      sha256 = "sha256-XwCN6fcF6A8FxV6aWEs0DpJFZECN6xWtuEEYH9W9WSs=";
    };
    buildPhase = ":";
  };
  vim-colors-solarized = pkgs.vimUtils.buildVimPlugin {
    name = "vim-colors-solarized";
    src = pkgs.fetchFromGitHub {
      owner = "altercation";
      repo = "vim-colors-solarized";
      rev = "528a59f26d12278698bb946f8fb82a63711eec21";
      sha256 = "sha256-obLvaW7ulNr6dkMcMe4mCs3ROnz4eTnyfspDHVqloxU=";
    };
  };

in {
  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = with pkgs; [
    gcc
    gopls
    kubectl
    minikube
    python39
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

  programs.go = {
    enable = true;
    goPath = "go";
  };

  programs.gpg.enable = true;

  programs.jq = {
    enable = true;

    # Default jq color scheme, nixpkgs default is too light
    colors = {
      null = "1;30";
      false = "0;39";
      true = "0;39";
      numbers = "0;39";
      strings = "0;32";
      arrays = "1;39";
      objects = "1;39";
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";

    extraConfig = (builtins.readFile ./tmux.conf);
  };

  programs.vim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      completor
      indentLine
      vim-go
      vim-colors-solarized
    ];
    extraConfig = (builtins.readFile ./vimrc);
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    initExtra = ''
      # fish-like history searches
      bindkey '\e[A' history-beginning-search-backward
      bindkey '\e[B' history-beginning-search-forward

      # kubectl autocompletion zsh
      source <(kubectl completion zsh)
      complete -F __start_kubectl k
    '';
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

    shellAliases = {
      gst = "git status -s";
      k = "kubectl";
    };
  };

  #---------------------------------------------------------------------
  # Services
  #---------------------------------------------------------------------

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";
  };
}
