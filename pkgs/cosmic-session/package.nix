{
  lib,
  fetchFromGitHub,
  rustPlatform,
  bash,
  dbus,
  just,
  rust,
  stdenv,
  xdg-desktop-portal-cosmic,
}:
rustPlatform.buildRustPackage {
  pname = "cosmic-session";
  version = "0-unstable-2024-06-27";

  src = fetchFromGitHub {
    owner = "billksun";
    repo = "cosmic-niri-session";
    rev = "7b161069c5d85f76ed1398a4f850dfe5d4800112";
    sha256 = "1xz13vzgs4bkngzp6kxgxk7v563sz1y8dpq1lf4lfl4f9zf67l10";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "cosmic-notifications-util-0.1.0" = "sha256-GmTT7SFBqReBMe4GcNSym1YhsKtFQ/0hrDcwUqXkaBw=";
      "launch-pad-0.1.0" = "sha256-c+uawTQlg5SW8x7DOBG2Idv/AfIaCFNtLQLUz8ifT2I=";
    };
  };

  postPatch = ''
    substituteInPlace Justfile \
      --replace-fail 'target/release/cosmic-session' "target/${rust.lib.toRustTargetSpecShort stdenv.hostPlatform}/release/cosmic-session"
    substituteInPlace data/start-cosmic \
      --replace-fail '/usr/bin/cosmic-session' '${placeholder "out"}/bin/cosmic-session' \
      --replace-fail '/usr/bin/dbus-run-session' '${lib.getExe' dbus "dbus-run-session"}'
    substituteInPlace data/cosmic.desktop \
      --replace-fail '/usr/bin/start-cosmic' '${placeholder "out"}/bin/start-cosmic'
  '';

  nativeBuildInputs = [ just ];
  buildInputs = [ bash ];

  dontUseJustBuild = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
  ];

  env.XDP_COSMIC = lib.getExe xdg-desktop-portal-cosmic;

  passthru.providedSessions = [ "cosmic" ];

  meta = with lib; {
    homepage = "https://github.com/pop-os/cosmic-session";
    description = "Session manager for the COSMIC desktop environment";
    license = licenses.gpl3Only;
    mainProgram = "cosmic-session";
    maintainers = with maintainers; [
      a-kenji
      nyanbinary
      lilyinstarlight
    ];
    platforms = platforms.linux;
  };
}
