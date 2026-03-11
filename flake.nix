{
  description = "Zig GTK4 Sample";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              zig
              pkg-config
              gtk4
              adwaita-icon-theme
              hicolor-icon-theme
              wrapGAppsHook4
            ];
            shellHook = ''
              export PKG_CONFIG_PATH="${pkgs.lib.makeSearchPath "lib/pkgconfig" [
                pkgs.gtk4.dev
                pkgs.glib.dev
              ]}"
              export XDG_DATA_DIRS="${pkgs.lib.makeSearchPath "share" [
                pkgs.adwaita-icon-theme
                pkgs.hicolor-icon-theme
                pkgs.gtk4
              ]}:$XDG_DATA_DIRS"
              export GSETTINGS_SCHEMA_DIR="${pkgs.glib.out}/share/gsettings-schemas/${pkgs.glib.name}:${pkgs.gtk4.out}/share/gsettings-schemas/${pkgs.gtk4.name}:$GSETTINGS_SCHEMA_DIR"
            '';
          };
        });

      packages = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.stdenv.mkDerivation {
            pname = "zig-gtk-sample";
            version = "0.1.0";
            src = ./.;

            nativeBuildInputs = with pkgs; [
              zig
              pkg-config
              wrapGAppsHook4
            ];

            buildInputs = with pkgs; [
              gtk4
              adwaita-icon-theme
              hicolor-icon-theme
            ];

            buildPhase = ''
              export HOME=$TMPDIR
              zig build -Doptimize=ReleaseSafe --verbose --verbose-link --verbose-cc
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp zig-out/bin/zig-gtk-sample $out/bin/
            '';
          };
        });
    };
}
