{
  description = "WinBoat flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    winboat = {
      url = "https://github.com/TibixDev/winboat/releases/download/v0.7.10/winboat-0.7.10-x86_64.AppImage";
      flake = false;
    };
  };

  outputs = inputs @ {
    flake-parts,
    winboat,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        packages.default = let
          pname = "winboat";
          name = pname;

          version = "0.7.10";

          img = {
            inherit pname version;

            src = winboat;

            extraPkgs = pkgs:
              with pkgs; [
                freerdp
              ];
          };

          icon = "${pkgs.appimageTools.extract img}/winboat.png";
          wrapped = "sg docker ${(pkgs.appimageTools.wrapType2 img)}/bin/winboat";

          desktopItem = pkgs.makeDesktopItem {
            inherit icon name;

            categories = ["Utility"];
            comment = "Run Windows apps on Linux";
            desktopName = "WinBoat";
            exec = wrapped;
          };
        in
          pkgs.stdenvNoCC.mkDerivation {
            inherit name;
            dontUnpack = true;

            installPhase = let
              binPath = "$out/bin/winboat";
            in ''
              mkdir -p $out/bin
              echo "${wrapped} $@" > ${binPath}
              chmod +x ${binPath}
              ln -s ${desktopItem}/share $out
            '';
          };
      };
    };
}
