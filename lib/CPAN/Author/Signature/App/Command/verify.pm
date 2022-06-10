package CPAN::Author::Signature::App::Command::verify;
use strict;

use CPAN::Author::Signature::App -command;
use experimental qw(signatures);
use Smart::Comments;
use HTTP::Tiny;
use MetaCPAN::Client;
use File::Slurp;
use File::Temp;
use File::Basename;
use Carp;

sub opt_spec {
  return (
    [ "allowed-signers|f=s",  "allowed signers file", ],
    [ "authorized-keys|F=s",  "allowed authorized keys", ],
    [ "author|a=s", "CPAN Author name"],
    [ "signature|s=s", "Signature file"],
  );
}

sub validate_args ($self, $opt, $args) {


  return $self->usage_error("author not provided")
    unless ($opt->{author});

  return $self->usage_error("author does not match expected format")
    unless ($opt->{author} =~ m/^[A-Z0-9]{2,32}$/);

  return $self->usage_error("no file to verify provided")
    unless @$args;

  return $self->usage_error("only one file is supported")
    if @$args > 1;

  return $self->usage_error("file $args->[0] does not exist") unless -f
    $args->[0];

  return;
}

sub execute ($self, $opt, $args) {
  my $signers_file   = $opt->{allowed_signers};
  my $signature_file = $opt->{signature};

  my $author         = $opt->{author};

  my ($file) = @$args;
  my $file_basename = basename($file);

  my $identity    = "$author\@author.cpan.org";
  my $namespace   = "$author/$file_basename\@author.cpan.org";

  unless ($signature_file) {
    if (-f "$file.sig") {
      $signature_file = "$file.sig";
    } else {
      return $self->usage_error("signature not provided");
    }
  } else {
    die unless -f $signature_file;
  }
  unless ($signers_file) {
    my $keys;
    if ($opt->{authorized_keys}) {
      $keys = read_file($opt->{authorized_keys});
    } else {
      $keys = $self->fetch_keys($author);
    }

    my $signers_string = $self->keys_to_signers($keys, $opt->{author});
    my $tmp = File::Temp->new(UNLINK => 0);
    print $tmp $signers_string;
    $signers_file = "$tmp";
  }

  my @cmd = ( "ssh-keygen",
              "-Y" => "verify",
              "-f" => $signers_file,
              "-I" => $identity,
              "-n" => $namespace,
              "-s" => $signature_file );

  open (my $fh, "<:raw", $file) or croak($!);
  open (my $keygen, "|-:raw", @cmd) or croak($!);

  while (1) {
    my $buf = '';
    my $s = read($fh, $buf, 2**16, 0);
    die $! unless defined $s;
    last unless $s;
    print $keygen $buf;
  }
  close $fh;
  close $keygen;

  my $exit = $?;

  die "FAILED VERIFY (Exit: $exit)\n"
    if ($exit);

}

sub keys_to_signers($self, $keys, $author) {
  my $identity    = "$author\@author.cpan.org";
  my $namespace   = "$author/*\@author.cpan.org";
  my @lines = grep { /^[ -~]+$/ } split(/\r?\n/, $keys);
  die "no keys" unless @lines;
  my $signers = join "\n", map {
    "$identity namespaces=\"$namespace\" $_"
  } @lines;
  return $signers;
}

sub fetch_keys ($self, $author) {
  my $a = $self->fetch_metacpan_author($author);
  return unless $a->profile;
  my ($github_handle,$more) =
    map { $_->{id} }
    grep { $_->{name} eq 'github' }
    @{$a->profile};

  unless ($github_handle) {
    die "Cannot find github profile for author $author";
  } elsif (defined $more) {
    die "More than 1 github handle not supported";
  }

  return $self->fetch_github_keys($github_handle);
}

sub fetch_github_keys($self, $handle) {
  my $url = "https://github.com/$handle.keys";
  $self->log("Fetching keys from $url");
  my $response = HTTP::Tiny->new->get($url);
  die "Failed!\n" unless $response->{success};
  return $response->{content};
}

sub fetch_gitlab_keys($self, $handle) {
  my $url = "https://github.com/$handle.keys";
  my $response = HTTP::Tiny->new->get($url);
  die "Failed!\n" unless $response->{success};
  return $response->{content};
}


sub fetch_metacpan_author($self, $author) {
  my $mcpan = MetaCPAN::Client->new;
  $self->log("Fetching author data for $author from MetaCPAN");
  my $author = $mcpan->author($author);
  return $author;
}

# ssh-keygen -v -Y verify -f trusted-cpan-stigtsp -I STIGTSP@cpan.org -n https://cpan.org/authors/id/S/ST/STIGTSP/Net-CIDR-Lite-0.22.tar.gz -s Net-CIDR-Lite-0.22.tar.gz.sig < Net-CIDR-Lite-0.22.tar.gz

1;
