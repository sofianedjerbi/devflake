{pkgs, ...}: let
  pname = "cursor";
  version = "0.47.5";

  src = pkgs.fetchurl {
    # URL to download the Cursor AppImage
    url = "https://downloads.cursor.com/production/b6fb41b5f36bda05cab7109606e7404a65d1ff32/linux/x64/Cursor-0.47.9-x86_64.AppImage";
    hash = "sha256-L0ZODGHmO8SDhqrnkq7jwi30c6l+/ESj+FXHVKghsfc=";
  };
  appimageContents = pkgs.appimageTools.extract {inherit pname version src;};
in
  with pkgs;
    appimageTools.wrapType2 {
      inherit pname version src;
      extraInstallCommands = ''
        # Find the desktop file (different AppImages might name it differently)
        DESKTOP_FILE=$(find ${appimageContents} -name "*.desktop" -type f -print -quit)
        if [ -z "$DESKTOP_FILE" ]; then
          echo "No desktop file found!"
          exit 1
        fi
        
        # Create applications directory if it doesn't exist
        mkdir -p $out/share/applications
        
        # Copy and fix the desktop file
        cp -v "$DESKTOP_FILE" $out/share/applications/${pname}.desktop
        
        # Fix the desktop file Exec pattern - find the actual pattern first
        sed -i "s|Exec=.*|Exec=${pname}|g" $out/share/applications/${pname}.desktop
        
        # Copy icons if they exist
        if [ -d "${appimageContents}/usr/share/icons" ]; then
          mkdir -p $out/share
          cp -r ${appimageContents}/usr/share/icons $out/share
        fi

        # Create a symlink for easier access - only if it doesn't exist
        if [ ! -e "$out/bin/${pname}" ]; then
          ln -sv $out/bin/${pname}-${version} $out/bin/${pname}
        fi
      '';

      extraBwrapArgs = [
        "--bind-try /etc/nixos/ /etc/nixos/"
      ];

      # vscode likes to kill the parent so that the
      # gui application isn't attached to the terminal session
      dieWithParent = false;

      extraPkgs = pkgs: [
        unzip
        autoPatchelfHook
        asar
        # override doesn't preserve splicing https://github.com/NixOS/nixpkgs/issues/132651
        (buildPackages.wrapGAppsHook.override {inherit (buildPackages) makeWrapper;})
      ];
    } 