{
  description = "A modified Discord Linux build";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }:
    let
      version = "moonlight-1.0.0";
      # tarball '...' contains an unexpected number of top-level files
      discord-electron = builtins.fetchurl {
        url =
          "https://github.com/moonlight-mod/discord-electron/releases/download/${version}/electron.tar.gz";
        sha256 = "sha256:0c95bwa58x4hy416pf9lcw0brkgb4ypv12y5qnjqzcd7icp812lm";
      };
      venmic = ./venmic.node;

      nameTable = {
        discord = "Discord";
        discord-ptb = "DiscordPTB";
        discord-canary = "DiscordCanary";
        discord-development = "DiscordDevelopment";
      };

      mkOverride = prev: discord-electron: name:
        let
          discord = prev.${name};
          folderName = nameTable.${name};
        in discord.overrideAttrs (old: {
          inherit name;
          # For venmic
          nativeBuildInputs = old.nativeBuildInputs
            ++ [ prev.pipewire prev.pulseaudio ];

          # Needed to make the process get past zygote_linux fork()'ing
          runtimeDependencies = [ prev.systemd ];

          installPhase = old.installPhase + "\n" + ''
            dir=$out/opt/${folderName}

            # Delete everything but these
            mv $dir/${name}.desktop $out
            mv $dir/discord.png $out
            mv $dir/postinst.sh $out
            mv $dir/resources $out

            # Extract our Electron
            tar -xf ${discord-electron} -C $dir
            mv $dir/electron $dir/${folderName}

            # Copy venmic
            cp ${venmic} $dir/venmic.node

            # Put back the files we kept
            mv $out/${name}.desktop $dir
            mv $out/discord.png $dir
            mv $out/postinst.sh $dir
            mv $out/resources $dir
          '';
        });

      overlay = final: prev: rec {
        discord = mkOverride prev discord-electron "discord";
        discord-ptb = mkOverride prev discord-electron "discord-ptb";
        discord-canary = mkOverride prev discord-electron "discord-canary";
        discord-development =
          mkOverride prev discord-electron "discord-development";
      };
    in let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay ];
      };
    in {
      packages.${system} = {
        discord-electron = discord-electron;
        discord = pkgs.discord;
        discord-ptb = pkgs.discord-ptb;
        discord-canary = pkgs.discord-canary;
        discord-development = pkgs.discord-development;
      };
    } // {
      overlays.default = overlay;
    };
}
