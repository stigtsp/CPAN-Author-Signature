package CPAN::Author::Signature;

use v5.20;
use experimental qw(signatures try);

use HTTP::Tiny;
use MetaCPAN::Client;
#use Log::Log4perl;
use Data::Dumper;

our $VERSION = '0.1';
our $SSH_KEYGEN = "ssh-keygen";

sub fetch_author_pubkeys ($author) {
  my $m =  MetaCPAN::Client->new()->author($author);
}



1;
