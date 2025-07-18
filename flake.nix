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
	riscv64MuslPkgs = let 
		pkgs = import nixpkgs {
             		inherit system;
              		crossSystem.config = "riscv64-unknown-linux-musl";
            	};
	  	in
	  	pkgs.pkgsCross.riscv64;
	cppInclude = "${riscv64MuslPkgs.pkgsStatic.stdenv.cc.cc}/include/c++/${riscv64MuslPkgs.pkgsStatic.stdenv.cc.version}";
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
		
		BINDGEN_EXTRA_CLANG_ARGS_riscv64gc_unknown_linux_musl="--sysroot=${riscv64MuslPkgs.pkgsStatic.stdenv.cc.libc.dev} -isystem ${cppInclude} -isystem ${cppInclude}/riscv64-unknown-linux-musl";
		buildInputs = with pkgs; 
			[
	      			libclang
	      			riscv64MuslPkgs.pkgsStatic.stdenv.cc
	      			rustToolchain
				python310	
				stgit
				ccache		
			];	
	  };
        });
}
