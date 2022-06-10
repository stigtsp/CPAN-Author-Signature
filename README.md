# CPAN::Author::Signature

Tool for author signing CPAN distribution using openssh >= 8, experimental.

``` sh
[nix-shell:~/opensource/CPAN-Author-Signature]$ bin/cpan-author-signature sign -f ~/.ssh/id_rsa.pub -a STIGTSP ~/Foobar-0.1.tar.gz
Signing file /home/sgo/Foobar-0.1.tar.gz
Write signature to /home/sgo/Foobar-0.1.tar.gz.sig

[nix-shell:~/opensource/CPAN-Author-Signature]$ bin/cpan-author-signature verify  -a STIGTSP ~/Foobar-0.1.tar.gz
[178736] Fetching author data for STIGTSP from MetaCPAN
[178736] Fetching keys from https://github.com/stigtsp.keys
Good "STIGTSP/Foobar-0.1.tar.gz@author.cpan.org" signature for STIGTSP@author.cpan.org with RSA key SHA256:+gAffbRajlOpGoQFBlmjVck0oAbjwVulqvwQoX3NnWY

```

