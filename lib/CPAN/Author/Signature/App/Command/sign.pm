package CPAN::Author::Signature::App::Command::sign;
use strict;

use CPAN::Author::Signature::App -command;
use experimental qw(signatures);
use Smart::Comments;
use File::Basename;

sub opt_spec {
  return (
    [ "author|a=s", "CPAN Author name"],
    [ "key-file|f=s", "SSH key file"],
  );
}

sub validate_args ($self, $opt, $args) {

  return $self->usage_error("author not provided")
    unless ($opt->{author});

  return $self->usage_error("author does not match expected format")
    unless ($opt->{author} =~ m/^[A-Z0-9]{2,32}$/);

  return $self->usage_error("ssh key file not provided")
    unless ($opt->{key_file});

  return $self->usage_error("ssh key file does not exist")
    unless (-f $opt->{key_file});

  return $self->usage_error("no file to sign provided")
    unless @$args;

  return $self->usage_error("only one file is supported")
    if @$args > 1;

  return $self->usage_error("file $args->[0] does not exist") unless -f
    $args->[0];

}

sub execute ($self, $opt, $args) {
  my ($file) = @$args;
  my $file_basename = basename($file);
  my $author      = $opt->{author};
  my $identity    = "$author\@author.cpan.org";
  my $namespace   = "$author/$file_basename\@author.cpan.org";
  my $key_file    = $opt->{key_file};


  my @cmd = ( "ssh-keygen",
              "-Y" => "sign",
              "-f" => $key_file,
              "-I" => $identity,
              "-n" => $namespace,
              $file);
  my $exit = system(@cmd);

  die "FAILED SIGN (Exit: $exit)\n"
    if ($exit);

}

1;
