{pkgs, ...}: let
  pname = "cursor";
  version = "0.48.6";

  src = pkgs.fetchurl {
    # URL to download the Cursor AppImage
    url = "https://downloads.cursor.com/production/66290080aae40d23364ba2371832bda0933a3641/linux/x64/Cursor-0.48.7-x86_64.AppImage";
    hash = "sha256-nnPbv74DOcOqgnAqW2IZ1S/lVbfv8pSe6Ab5BOdzkrs=";
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
        sed -i "s|Exec=.*|Exec=${pname} --disable-gpu-driver-bug-workarounds --ignore-gpu-blocklist --disable-features=UseChromeOSDirectVideoDecoder --enable-features=VaapiVideoDecoder,VaapiVideoEncoder --use-gl=desktop --enable-gpu-rasterization --enable-zero-copy|g" $out/share/applications/${pname}.desktop
        
        # Copy icons if they exist
        if [ -d "${appimageContents}/usr/share/icons" ]; then
          mkdir -p $out/share
          cp -r ${appimageContents}/usr/share/icons $out/share
        fi

        # Create a symlink for easier access - only if it doesn't exist
        if [ ! -e "$out/bin/${pname}" ]; then
          ln -sv $out/bin/${pname}-${version} $out/bin/${pname}
        fi
        
        # Create a vscode directory in etc with performance optimizations
        mkdir -p $out/etc/vscode
        cat > $out/etc/vscode/argv.json <<EOF
{
  "enable-crash-reporter": false,
  "disable-hardware-acceleration": false,
  "disable-color-correct-rendering": true,
  "disable-extensions": false,
  "disable-telemetry": true,
  "disable-updates": true,
  "enable-proposed-api": ["ms-vscode.vscode-js-profile-flame"],
  "force-disable-user-env": false,
  "force-renderer-accessibility": false,
  "js-flags": "--max-old-space-size=4096 --expose-gc",
  "max-memory": 4096
}
EOF
        
        # Create settings.json with dev container optimizations
        mkdir -p $out/share/code/User
        cat > $out/share/code/User/settings.json <<EOF
{
  "editor.accessibilitySupport": "off",
  "workbench.enableExperiments": false,
  "workbench.settings.enableNaturalLanguageSearch": false,
  "update.mode": "none",
  "extensions.autoCheckUpdates": false,
  "extensions.autoUpdate": false,
  "telemetry.telemetryLevel": "off",
  "npm.fetchOnlinePackageInfo": false,
  "terminal.integrated.gpuAcceleration": "on",
  "window.titleBarStyle": "custom",
  "window.dialogStyle": "custom",
  "window.customTitleBarVisibility": "auto",
  "files.useExperimentalFileWatcher": true,
  "remote.downloadExtensionsLocally": true,
  "remote.WSL.fileWatcher.pollingInterval": 5000,
  "remote.containers.cachePath": "/tmp/vscode-remote-containers",
  "editor.suggest.preview": false,
  "search.searchOnType": false,
  "search.followSymlinks": false,
  "extensions.ignoreRecommendations": true
}
EOF
      '';

      extraBwrapArgs = [
        "--bind-try /etc/nixos/ /etc/nixos/"
        "--bind-try /var/run/docker.sock /var/run/docker.sock"
        "--bind-try /tmp /tmp"
        "--dev-bind /dev/dri /dev/dri"
        "--ro-bind-try /sys/dev/char /sys/dev/char"
        "--ro-bind-try /sys/devices/pci0000:00 /sys/devices/pci0000:00"
      ];

      # vscode likes to kill the parent so that the
      # gui application isn't attached to the terminal session
      dieWithParent = false;

      extraPkgs = pkgs: with pkgs; [
        unzip
        autoPatchelfHook
        asar
        # override doesn't preserve splicing https://github.com/NixOS/nixpkgs/issues/132651
        (buildPackages.wrapGAppsHook.override {inherit (buildPackages) makeWrapper;})
        # Added packages for better performance
        mesa
        libdrm
        libva
        xorg.libxshmfence
        vulkan-loader
        glxinfo
      ];
    }
