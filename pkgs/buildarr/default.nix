{
  lib,
  python3,
  fetchFromGitHub,
  click-params,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "buildarr";
  #version = "0.8.0b1";
  version = "0.7.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "buildarr";
    repo = "buildarr";
    rev = "v${version}";
    hash = "sha256-MMpPFUXicGlreXxvYoGcVEct8ICyuvoRQKxpmRi4jSo="; # v0.7.1
    #hash = "sha256-2lXUW4B3KfIOn1tS9RsjwDoy/Hom4bXbO4vdd8NXoZQ="; # v0.8.0b1 - currently has incompatibilities with downstream packages
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core # v0.7.1 requires poetry-core
    #pdm-pep517
    #setuptools-scm
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aenum
    click
    click-params
    importlib-metadata
    #pydantic
    #v0.7.1 requires pydantic < 2.0.0
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
    pyyaml
    requests
    schedule
    stevedore
    typing-extensions
    watchdog
  ];

  pythonImportsCheck = [
    "buildarr"
  ];

  meta = {
    description = "Constructs and configures Arr PVR stacks";
    homepage = "https://github.com/buildarr/buildarr";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [hierocles];
    mainProgram = "buildarr";
  };
}
