## no critic: TestingAndDebugging::RequireUseStrict
package ScriptX::Getopt::Long;

use parent 'ScriptX_Base';

# AUTHORITY
# DATE
# DIST
# VERSION

sub meta {
    return {
        summary => 'Parse command-line options using Getop::Long',
        conf => {
            spec => {
                summary => "Specification to be passed to Getopt::Long's GetOptions",
                schema => 'array*',
                req => 1,
            },
            abort_on_failure => {
                summary => 'Whether to abort script execution on GetOptions() failure',
                schema => 'bool*',
                default => 1,
            },
        },
    };
}

sub before_run {
    my ($self, $stash) = @_;

    my $abort_on_failure = $self->{abort_on_failure} // 1;

    require Getopt::Long;
    Getopt::Long::Configure("gnu_getopt", "no_ignore_case");
    my $res = Getopt::Long::GetOptions(@{ $self->{spec} });
    $res ? [200] : [$abort_on_failure ? 601 : 500, "GetOptions failed"];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use ScriptX::Getopt::Long => {
     spec => [
         'foo=s' => sub { ... },
         'bar'   => sub { ... },
     ],
 };


=head1 DESCRIPTION

This plugin basically just configures L<Getopt::Long>:

 Getopt::Long::Configure("gnu_getopt", "no_ignore_case");

then pass the spec to C<GetOptions()>.


=head1 SEE ALSO

L<Getopt::Long>

L<ScriptX::Getopt::Specless>
