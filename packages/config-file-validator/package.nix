{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
}:

buildGoModule rec {
  pname = "config-file-validator";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "Boeing";
    repo = "config-file-validator";
    rev = "v${version}";
    hash = "sha256-PIhT8JXs6hoU/kI+ZbZ2kFSRD1g64gqZmO2cv8Bpf9M=";
  };

  vendorHash = "sha256-7bt4F8sk2936NWK5LVoZDMhg0y3jt09kb/eqJyH9ges=";

  subPackages = [ "cmd/validator" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/Boeing/config-file-validator/v2.version=v${version}"
  ];

  nativeCheckInputs = [ git ];

  postPatch = ''
    substituteInPlace cmd/validator/testdata/gitignore.txtar \
      --replace-fail "! stdout 'build'" "! stdout 'build.output.json'"
    substituteInPlace cmd/validator/testdata/ignore_file.txtar \
      --replace-fail "! stdout 'build'" "! stdout 'build.output.json'"
  '';

  meta = {
    description = "CLI for validating configuration files";
    homepage = "https://github.com/Boeing/config-file-validator";
    changelog = "https://github.com/Boeing/config-file-validator/releases/tag/v${version}";
    license = lib.licenses.asl20;
    mainProgram = "validator";
    platforms = lib.platforms.unix;
  };
}
