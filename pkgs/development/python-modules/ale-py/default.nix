{ buildPythonPackage
, SDL2
, cmake
, fetchFromGitHub
, git
, gym
, importlib-metadata
, importlib-resources
, lib
, ninja
, numpy
, pybind11
, pytestCheckHook
, python
, pythonOlder
, setuptools
, stdenv
, typing-extensions
, wheel
, zlib
}:

buildPythonPackage rec {
  pname = "ale-py";
  version = "0.8.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "mgbellemare";
    repo = "Arcade-Learning-Environment";
    rev = "v${version}";
    sha256 = "sha256-OPAtCc2RapK1lALTKHd95bkigxcZ9bcONu32I/91HIg=";
  };

  patches = [
    # don't download pybind11, use local pybind11
    ./cmake-pybind11.patch
  ];

  nativeBuildInputs = [
    cmake
    setuptools
    wheel
    pybind11
  ];

  buildInputs = [
    zlib
    SDL2
  ];

  propagatedBuildInputs = [
    typing-extensions
    importlib-resources
    numpy
  ] ++ lib.optionals (pythonOlder "3.10") [
    importlib-metadata
  ];

  checkInputs = [
    pytestCheckHook
    gym
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'dynamic = ["version"]' 'version = "${version}"'
    substituteInPlace setup.py \
      --replace 'subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd=here)' 'b"${src.rev}"'
  '';

  dontUseCmakeConfigure = true;

  pythonImportsCheck = [ "ale_py" ];

  meta = with lib; {
    description = "a simple framework that allows researchers and hobbyists to develop AI agents for Atari 2600 games";
    homepage = "https://github.com/mgbellemare/Arcade-Learning-Environment";
    license = licenses.gpl2;
    maintainers = with maintainers; [ billhuang ];
    broken = stdenv.isDarwin; # fails to link with missing library
  };
}
