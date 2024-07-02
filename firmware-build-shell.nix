{
  buildFHSEnv,
  toolchain,
  toolchainDir ? "opt/toolchains/crosstools-arm-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21-NPTL",
}:
(buildFHSEnv {
  name = "firmware-build-env";

  targetPkgs =
    pkgs:
    [
      pkgs.gcc

      # undocumented deps
      pkgs.libuuid
      pkgs.lzo
    ]
    ++ pkgs.linux.nativeBuildInputs;

  extraOutputsToInstall = [ "dev" ];

  extraBuildCommands = ''
    mkdir -p ${toolchainDir}
    ln -s ${toolchain} ${toolchainDir}/usr
  '';

  profile = ''
    export PATH=/${toolchainDir}/usr/bin:"$PATH"
  '';
}).env
