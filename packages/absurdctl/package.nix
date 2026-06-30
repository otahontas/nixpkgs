{
  lib,
  fetchPypi,
  postgresql,
  python3Packages,
}:

let
  data = lib.importJSON ./hashes.json;
in
python3Packages.buildPythonApplication {
  pname = "absurdctl";
  version = data.version;
  format = "wheel";

  src = fetchPypi {
    pname = "absurdctl";
    inherit (data) version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    abi = "none";
    platform = "any";
    hash = data.sourceHash;
  };

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ postgresql ])
  ];

  doCheck = false;

  doInstallCheck = true;
  installCheckPhase = ''
    test -x "$out/bin/absurdctl"
    "$out/bin/absurdctl" --help > /dev/null
  '';

  meta = with lib; {
    description = "Python CLI for managing Absurd schemas, queues, tasks, and events";
    homepage = "https://github.com/earendil-works/absurd";
    changelog = "https://github.com/earendil-works/absurd/releases";
    downloadPage = "https://pypi.org/project/absurdctl/";
    license = licenses.asl20;
    mainProgram = "absurdctl";
    platforms = platforms.unix;
  };
}
