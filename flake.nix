{
  description = "LaTeX Document Demo";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    with flake-utils.lib;
    eachSystem allSystems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [ "brill" ];
        };
        tex = pkgs.texlive.combine { inherit (pkgs.texlive) scheme-small latex-bin latexmk; };
        fontsConf = pkgs.makeFontsConf { fontDirectories = [ pkgs.brill ]; };
      in
      rec {
        packages = {
          document = pkgs.stdenvNoCC.mkDerivation rec {
            name = "latex-base";
            src = self;
            buildInputs = [
              pkgs.coreutils
              pkgs.fontconfig
              pkgs.brill
              tex
            ];
            phases = [
              "unpackPhase"
              "buildPhase"
              "installPhase"
            ];
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath buildInputs}";
              export OSFONTDIR=${pkgs.brill}/share/fonts/truetype

              env HOME=$(mktemp -d) \
                FONTCONFIG_FILE=${fontsConf} \
                SOURCE_DATE_EPOCH=${toString self.lastModified} \
                latexmk -interaction=nonstopmode -pdf -lualatex \
                -pretex="\pdfvariable suppressoptionalinfo 512\relax" \
                -usepretex main.tex
            '';
            installPhase = ''
              mkdir -p $out
              cp main.pdf $out/
            '';
          };
        };
        defaultPackage = packages.document;
      }
    );
}
