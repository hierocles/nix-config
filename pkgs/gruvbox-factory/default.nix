{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "gruvbox-factory";
  version = "1.0.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "paulopacitti";
    repo = "gruvbox-factory";
    rev = "v${version}";
    hash = "sha256-4N7bF0nQBKTAkY45Ji32eLq35rK9LxumkvsgcocBB1Q=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    (image-go-nord.overridePythonAttrs (old: {
      version = "1.2.0";
      src = fetchFromGitHub {
        owner = "schroedinger-hat";
        repo = "ImageGoNord-pip";
        rev = "refs/tags/v1.2.0";
        hash = "sha256-rPp4QrkbDhrdpfynRUYgxpNgUNxU+3h54Ea7s/+u1kI=";
      };
      propagatedBuildInputs = old.propagatedBuildInputs ++ [numpy ffmpeg-python requests];
    }))
    rich
  ];

  meta = {
    description = "Convert any image to the gruvbox pallete";
    homepage = "https://github.com/paulopacitti/gruvbox-factory";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [hierocles];
    mainProgram = "gruvbox-factory";
  };
}
