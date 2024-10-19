{
  lib,
  python3,
  fetchFromGitHub,
  buildarr,
  buildarr-sonarr,
  buildarr-radarr,
}: let
  prowlarr-py = python3.pkgs.buildPythonPackage rec {
    pname = "prowlarr-py";
    version = "0.4.1";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "devopsarr";
      repo = "prowlarr-py";
      rev = "v${version}";
      hash = "sha256-2QR5BnbzOxS6/ivtX5NCn/+Cp3/h4kySV6lhj0+kAcA=";
    };

    nativeBuildInputs = with python3.pkgs; [
      setuptools
      wheel
    ];

    propagatedBuildInputs = with python3.pkgs; [
      urllib3
      python-dateutil
      (pydantic.overridePythonAttrs (old: {
        version = "1.10.11";
        src = python3.pkgs.fetchPypi {
          pname = "pydantic";
          version = "1.10.11";
          hash = "sha256-9m1HnPfrMxNyxHBhS+ZRHq6W8fEgNEwl8/m7WfsbVSg=";
        };
        nativeBuildInputs = with python3.pkgs; [
          setuptools
        ];
        propagatedBuildInputs = with python3.pkgs; [
          typing-extensions
          devtools
          email-validator
          python-dotenv
          distutils
        ];
        # Disable the pytest check phase
        doCheck = false;
      }))
      typing-extensions
      requests
      aenum
    ];

    pythonImportsCheck = ["prowlarr"];

    meta = with lib; {
      description = "Prowlarr API wrapper";
      homepage = "https://github.com/devopsarr/prowlarr-py";
      license = licenses.mpl20;
    };
  };
in
  python3.pkgs.buildPythonApplication rec {
    pname = "buildarr-prowlarr";
    version = "0.5.3";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "buildarr";
      repo = "buildarr-prowlarr";
      rev = "v${version}";
      hash = "sha256-Az5SRjgkNDthdDTsqniKAwz/J6EisDkXAqR5/0UQets=";
    };

    nativeBuildInputs = with python3.pkgs; [
      poetry-core
    ];

    buildInputs = [
      prowlarr-py
    ];

    propagatedBuildInputs =
      [
        buildarr
        buildarr-sonarr
        buildarr-radarr
        prowlarr-py
      ]
      ++ (with python3.pkgs; [
        dateutil
      ]);

    makeWrapperArgs = [
      "--prefix PYTHONPATH : ${prowlarr-py}/${python3.sitePackages}"
    ];

    pythonImportsCheck = [
      "buildarr_prowlarr"
      "buildarr"
    ];

    meta = {
      description = "Prowlarr PVR plugin for Buildarr";
      homepage = "https://github.com/buildarr/buildarr-prowlarr";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [hierocles];
      mainProgram = "buildarr";
    };
  }
