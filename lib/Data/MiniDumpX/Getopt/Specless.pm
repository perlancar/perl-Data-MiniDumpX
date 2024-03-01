## no critic: TestingAndDebugging::RequireUseStrict
package ScriptX::Getopt::Specless;

use strict;
use warnings;

use parent 'ScriptX_Base';

# AUTHORITY
# DATE
# DIST
# VERSION

sub meta {
    return {
        summary => 'Parse command-line options in a simple, spec-less way',
        description => <<'_',

This plugin parses command-line options from command-line arguments in a simple
way. All argument that begins with `-` (e.g. `-foo`) or `--` (`--foo`) is
assumed to be a option. Option value must be specified using this syntax
`-foo=VAL` or `--foo=VAL` instead of `-foo VAL` or `--foo VAL`. Option
processing stops after `--` or until the last argument.

Example:

     --foo --bar=amber --baz --baz -- arg1 --qux

will result in the `opts` stash variable being set to:

    {foo => 1, bar=>'amber', baz => 1}

and `argv` to:

    ['arg1', '--qux']

_
        conf => {
        },
    };
}

sub before_run {
    my ($self, $stash) = @_;

    my $argv = $stash->{argv} || [@ARGV];
    my $i = 0;
    my $opts = {};
    my $new_argv = [];
    while ($i <= $#{ $argv }) {
        my $arg = $argv->[$i];
        #print "D:arg=$arg\n";
        if ($arg eq '--') {
            push @$new_argv, @{ $argv }[$i+1 .. $#{ $argv }];
            last;
        }
        if ($arg =~ /\A--?/) {
            $arg =~ /\A--?([\w-]+)(?:(=)(.*))?\z/
                or die "Invalid option syntax '$arg'";
            $opts->{$1} = $2 ? $3 : 1;
        } else {
            push @$new_argv, $arg;
        }
        $i++;
    }

    $stash->{opts} = $opts;
    $stash->{argv} = $new_argv;

    [200];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In your script:

 use ScriptX (
     'Getopt::Specless',
     'Run' => {code => sub { my ($self, $stash) = @_; my $opts = $stash->{opts}; print "You specified --foo!\n" if $opts->{foo} }},
 ;

On the command-line:

 % ./yourscript.pl

 % ./yourscript.pl --foo --bar=val --baz arg1 arg2
 You specified --foo!


=head1 DESCRIPTION

This is an alternative to L<ScriptX::Getopt::Long> if you don't want to use
L<Getopt::Long>.


=head1 SEE ALSO

L<ScriptX::Getopt::Long>
