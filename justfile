build:
	mkdir -p build
	lualatex -interaction=nonstopmode -output-directory=build main.tex

build-nix:
	nix build -o build-nix --no-sandbox '.?submodules=1'

nixfmt:
	nix-shell -p nixfmt --command 'nixfmt -s *.nix'
