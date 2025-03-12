{
  description = "Nvidia BCM git-helpers tools flake";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11"; };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      lib = nixpkgs.lib;
      python = pkgs.python3.withPackages (ps: with ps; [ pygit2 ]);
    in {
      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation {
        pname = "git-helpers";
        version = "1.0.0";

        src = ./.;

        buildInputs = with pkgs; [ python makeWrapper ronn ];

        buildPhase = ''
          cd man
          ${pkgs.bash}/bin/bash ./convert-to-man
        '';

        installPhase = ''
          # Install scripts
          mkdir -p $out/bin
          cp $src/bin/* $out/bin/

          chmod u+x $out/bin/git-bc-cherry-pick
          chmod u+x $out/bin/git-bc-log

          wrapProgram $out/bin/git-bc-show-eligible --prefix PATH : ${
            lib.makeBinPath [ python ]
          }

          # Install man pages
          mkdir -p $out/share/man/man1
          cp man1/* $out/share/man/man1
        '';
      };

      meta = with lib; {
        description = "Useful command line script used by the Nvidia BCM team";
        license = licenses.asl20;
      };
    };
}
