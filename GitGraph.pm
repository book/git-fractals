use strict;
use warnings;
use File::Path;
use Carp;

# some debug / verbose commands
my $debug = 0;
my $verbose = 0;

sub init {
    my ($dir) = @_;
    croak "$dir already exists" if -e $dir;

    # create the repository, and an empty tree in the object database
    mkpath( $dir );
    $ENV{GIT_DIR} = "$dir/.git";
    `git init;touch a;git add a;git commit -m empty;git rm a;git commit -m null;git checkout HEAD^;git branch -D master`;
}

sub set_git_repo {
    my ($dir) = @_;
    $ENV{GIT_DIR} = "$dir/.git";
}

# some initialisations
my $tree;
my $count = 0;
sub reset_count { $count = 0 }

sub node {
    my ($branch, @parents) = @_;

    # the node-creation command
    my $cmd = qq{echo $count | git commit-tree $tree @{[map {"-p $_"} @parents]}};
    print "$cmd\n" if $debug;
    $ENV{GIT_AUTHOR_DATE} = $ENV{GIT_COMMITTER_DATE} = $^T + $count;
    chomp( my $node = `$cmd` );
    print @parents ? join( ':', @parents ) . ' -> ' : '', $node, "\n" if $verbose;

    # set the branch position
    `git branch -f $branch $node`;

    # return the new node
    $count++;
    return $node;
}

# the empty tree SHA1
$tree = 
'4b825dc642cb6eb9a060e54bf8d69288fbee4904';

__END__

=head1 NAME

GitGraph - Function library to build graphs using git

=head1 SYNOPSIS

    use GitGraph;

    # initialize an empty repository
    init('repo');
    my $branch = 'master';

    # create a parentless node, and point the branch to it
    my $node = node($branch);

    # create a child node
    my $child = node( $branch, $node );

    # create a merge node
    my $merge = node( $branch, $child, $node );

=head1 DESCRIPTION

This module aims at creating graph structures using git.
Each node  of the graph is a commit that points to the empty tree. 

The commit message is an integer, showing the order of creation.
(The first created commit is numbered C<1>, etc.)

B<Warning:> The current version of C<GitGraph> can only handle a single
git repository at a time.

=head1 AUTHOR

Philippe Bruhat (BooK)

=cut

