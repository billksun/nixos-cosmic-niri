{ lib
, fetchFromGitHub
, rustPlatform
, libcosmicAppHook
, cmake
, coreutils
, just
, libinput
, linux-pam
, rust
, stdenv
, udev
, nix-update-script
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-greeter";
  version = "1.0.0-alpha.1-unstable-2024-08-15";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-greeter";
    rev = "3679ee55614f7c37f8a2eb9b52900024c186a576";
    sha256 = "sha256-QpHU9EOLoOL+HzbM9+FTAPZ6a51PyIJ00e337zUg7ns=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "accesskit-0.12.2" = "sha256-1UwgRyUe0PQrZrpS7574oNLi13fg5HpgILtZGW6JNtQ=";
      "atomicwrites-0.4.2" = "sha256-QZSuGPrJXh+svMeFWqAXoqZQxLq/WfIiamqvjJNVhxA=";
      "clipboard_macos-0.1.0" = "sha256-cG5vnkiyDlQnbEfV2sPbmBYKv1hd3pjJrymfZb8ziKk=";
      "cosmic-bg-config-0.1.0" = "sha256-keKTWghlKehLQA9J9SQjAvGCaZY/7xWWteDtmLoThD0=";
      "cosmic-client-toolkit-0.1.0" = "sha256-1XtyEvednEMN4MApxTQid4eed19dEN5ZBDt/XRjuda0=";
      "cosmic-comp-config-0.1.0" = "sha256-5+AY6p31XV+y+rrIU6YCg37oa4ygFPjYb+Osml1O29Q=";
      "cosmic-config-0.1.0" = "sha256-vkYq91Zvz8RNdXm5z26Rc3XaHtD2/PuUYfYJkORKdgE=";
      "cosmic-dbus-networkmanager-0.1.0" = "sha256-Bz/bzXCm60AF0inpZJDF4iNZIX3FssImORrE5nZpkyQ=";
      "cosmic-text-0.12.1" = "sha256-x0XTxzbmtE2d4XCG/Nuq3DzBpz15BbnjRRlirfNJEiU=";
      "d3d12-0.19.0" = "sha256-usrxQXWLGJDjmIdw1LBXtBvX+CchZDvE8fHC0LjvhD4=";
      "glyphon-0.5.0" = "sha256-j1HrbEpUBqazWqNfJhpyjWuxYAxkvbXzRKeSouUoPWg=";
      "smithay-clipboard-0.8.0" = "sha256-4InFXm0ahrqFrtNLeqIuE3yeOpxKZJZx+Bc0yQDtv34=";
      "softbuffer-0.4.1" = "sha256-a0bUFz6O8CWRweNt/OxTvflnPYwO5nm6vsyc/WcXyNg=";
      "taffy-0.3.11" = "sha256-SCx9GEIJjWdoNVyq+RZAGn0N71qraKZxf9ZWhvyzLaI=";
    };
  };

  nativeBuildInputs = [ libcosmicAppHook rustPlatform.bindgenHook cmake just ];
  buildInputs = [ libinput linux-pam udev ];

  cargoBuildFlags = [ "--all" ];

  dontUseJustBuild = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${rust.lib.toRustTargetSpecShort stdenv.hostPlatform}/release/cosmic-greeter"
    "--set"
    "daemon-src"
    "target/${rust.lib.toRustTargetSpecShort stdenv.hostPlatform}/release/cosmic-greeter-daemon"
  ];

  postPatch = ''
    substituteInPlace src/greeter.rs --replace-fail '/usr/bin/env' '${lib.getExe' coreutils "env"}'
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex" "epoch-(.*)" ];
  };

  meta = with lib; {
    homepage = "https://github.com/pop-os/cosmic-greeter";
    description = "Greeter for the COSMIC Desktop Environment";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ nyanbinary /*lilyinstarlight*/ ];
    platforms = platforms.linux;
  };
}
