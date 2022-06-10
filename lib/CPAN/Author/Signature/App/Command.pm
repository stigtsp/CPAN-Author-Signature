package CPAN::Author::Signature::App::Command;
use strict;
use experimental qw(signatures);

use App::Cmd::Setup -command;
use Log::Dispatchouli;

my $logger = Log::Dispatchouli->new({
  ident     => 'cpan-author-signature',
  to_stdout => 1,
});

sub log ($self, @rest) {
  return $logger->log(@rest);
}

1;
