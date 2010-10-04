use strict;
use warnings;
use File::Path;
use Carp;
use Git::Repository 1.12;

# some debug / verbose commands
my $debug = 0;
my $verbose = 0;

sub init {
    my ($dir) = @_;
    croak "$dir already exists" if -e $dir;

    # create the repository
    croak "Git > 1.6.5 required" if Git::Repository->version_lt( '1.6.5' );
    mkpath( $dir );
    my $r = Git::Repository->create( init => $dir );

    # add the empty tree in the object database
    $r->run( mktree => { input => '' } );

    return;
}

# some initialisations
my $tree;
my $count = 0;
sub reset_count { $count = 0 }

sub node {
    my ($r, $branch, @parents) = @_;

    # the node-creation command
    my @cmd = ( 'commit-tree', $tree, map { -p => $_} @parents );
    print "git @cmd\n" if $debug;
    my $node = $r->run( @cmd,
        { input => $count, env => { GIT_COMMITTER_DATE => $^T + $count } } );
    print @parents ? join( ':', @parents ) . ' -> ' : '', $node, "\n"
        if $verbose;

    # set the branch position
    $r->run( 'update-ref', "refs/heads/$branch", $node );

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

