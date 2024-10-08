{
  lib,
  python3,
  fetchFromGitHub,
}: let
  pythonPackages = python3.pkgs;
in
  pythonPackages.buildPythonPackage rec {
    pname = "click-params";
    version = "0.5.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "hierocles";
      repo = "click_params";
      rev = "update-validators";
      hash = "sha256-suINI6VZnpGtOVB9I/QzrEJHCJ0M+aurpsX2NWvkJx0=";
    };

    nativeBuildInputs = with pythonPackages; [
      poetry-core
    ];

    propagatedBuildInputs = with pythonPackages; [
      click
      deprecated
      validators
    ];

    pythonImportsCheck = [
      "click_params"
    ];

    meta = with lib; {
      description = "Bunch of click parameters to use";
      homepage = "https://github.com/click-contrib/click_params";
      changelog = "https://github.com/click-contrib/click_params/blob/${src.rev}/CHANGELOG.md";
      license = licenses.asl20;
      maintainers = with maintainers; [hierocles];
    };
  }
