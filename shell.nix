with import <nixpkgs> { } ;
with perlPackages;

pkgs.mkShell {
  buildInputs = [
    perl
    MetaCPANClient
    SmartComments
    AppCmd
    FileSlurp
    LogDispatchouli
  ];
  shellHook = ''
  export PERL5LIB="$(pwd)/lib:$PERL5LIB";
  '';
}
