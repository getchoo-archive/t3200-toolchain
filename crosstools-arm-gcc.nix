{
  stdenvNoCC,
  autoPatchelfHook,
  ncurses5,
  sourceRelease,
  releaseVersion,
}:
stdenvNoCC.mkDerivation {
  pname = "t3200-crosstools-arm-gcc";
  version = "4.6-${releaseVersion}";

  src = sourceRelease + "/crosstools-arm-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21-NPTL.tar.bz2";

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ ncurses5 ];

  installPhase = ''
    runHook preInstall

    mv toolchains/crosstools-arm-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21-NPTL $out
    rm $out/lib
    mv $out/usr/{,.}* $out
    rmdir $out/usr
    ln -sf $out/lib $out/arm-unknown-linux-uclibcgnueabi/sysroot/lib

    runHook postInstall
  '';
}
