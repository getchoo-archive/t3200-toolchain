{
  description = "Toolchain for Actiontec's T3200 Series DSL Gateway";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      # Since we're building 32-bit linux packages, we can only (usually) run this on
      # systems that are x86{,-64} and Linux themselves. This should evaluate to
      # [ "x86_64-linux" "i686-linux" ]
      systems = lib.intersectLists lib.platforms.linux lib.platforms.x86;

      forAllSystems = lib.genAttrs systems;
      nixpkgsFor = forAllSystems (
        system:
        let
          native = nixpkgs.legacyPackages.${system};
        in
        {
          inherit native;
          cross = {
            i686 = native.pkgsi686Linux;
          };
        }
      );
    in
    {
      formatter = forAllSystems (system: nixpkgsFor.${system}.native.nixfmt-rfc-style);

      packages = forAllSystems (
        system:
        let
          nixpkgsFor' = nixpkgsFor.${system};
          pkgs = nixpkgsFor'.native;
          pkgsi686 = nixpkgsFor'.cross.i686;

          # https://opensource.actiontec.com/t3200.html
          #
          # some of these releases contain different toolchains
          # no idea if any of these are meaningful changes, but lets
          # support multiple for fun
          releases = [
            {
              version = "31.164l.32";
              hash = "sha256-SRS9N1dpmvAksF6zWudUUv6DWL2TQVCte3x1PL8d02g=";
            }
            {
              version = "31.164l.33";
              hash = "sha256-tN31mGv27vUoIncM6xadhyiMdal4pdtFgn5tu5oFtF4=";
            }
          ];

          releaseInfo = map (
            { version, hash }:
            {
              inherit version;
              src = pkgs.fetchzip {
                url = "https://opensource.actiontec.com/sourcecode/t3200x/bt_bcm963xx_t3200_${version}_gpl_consumer_release.tar.gz";
                inherit hash;
                stripRoot = false;
              };
            }
          ) releases;

          releasePackages = map (
            { src, version }:
            {
              name = "toolchain-" + version;
              value = pkgsi686.callPackage ./crosstools-arm-gcc.nix {
                sourceRelease = src;
                releaseVersion = version;
              };
            }
          ) releaseInfo;
        in
        lib.listToAttrs releasePackages // { default = self.packages.${system}."toolchain-31.164l.33"; }
      );
    };
}
