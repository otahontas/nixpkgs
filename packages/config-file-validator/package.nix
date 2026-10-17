{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
}:

buildGoModule rec {
  pname = "config-file-validator";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "Boeing";
    repo = "config-file-validator";
    rev = "v${version}";
    hash = "sha256-v/6KbReW2qEd6Dkno7VCyegOBpCAYvC5GWuBMvZe12w=";
  };

  vendorHash = "sha256-uLS28SwapMqHmuWcEzUAtJGlOr4BvA5LQnn/L81SWus=";

  subPackages = [ "cmd/cfv" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/Boeing/config-file-validator/v3.version=v${version}"
  ];

  nativeCheckInputs = [ git ];

  postPatch = ''
    substituteInPlace cmd/cfv/testdata/gitignore.txtar \
      --replace-fail "! stdout 'build'" "! stdout 'build.output.json'"
    substituteInPlace cmd/cfv/testdata/ignore_file.txtar \
      --replace-fail "! stdout 'build'" "! stdout 'build.output.json'"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    test -x "$out/bin/cfv"
    "$out/bin/cfv" --version | grep -F "${version}"
  '';

  meta = {
    description = "CLI for validating configuration files";
    homepage = "https://github.com/Boeing/config-file-validator";
    changelog = "https://github.com/Boeing/config-file-validator/releases/tag/v${version}";
    license = lib.licenses.asl20;
    mainProgram = "cfv";
    platforms = lib.platforms.unix;
  };
}
