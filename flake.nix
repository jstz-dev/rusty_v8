{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };
  outputs = inputs:
    with inputs;
      flake-utils.lib.eachDefaultSystem (system: let 
	pkgs = import nixpkgs { inherit system; overlays = [(import rust-overlay)]; };
	llvmPackages = pkgs.llvmPackages_14;
	libclang = llvmPackages.libclang;
	rustToolchain = let
		toolchain = (builtins.fromTOML (builtins.readFile ./rust-toolchain.toml)).toolchain;
		in
		pkgs.rust-bin.fromRustupToolchain toolchain;
	in
        {
	   packages.default = pkgs.stdenv.mkDerivation rec {
           	name = "empty";
                src = null;
                phases = [];
                dontBuild = true;
                dontInstall = true;
            };

	   devShells.default = pkgs.mkShell {
	    	LIBCLANG_PATH = "${libclang.lib}/lib";
		
		buildInputs = with pkgs; 
			[
	      			rustToolchain
				python310	
				stgit
				ccache		
			];	
	  };
        });
}
