## no critic: TestingAndDebugging::RequireUseStrict
package Data::MiniDumpX;

# IFUNBUILT
use strict;
use warnings;
# END IFUNBUILT
use Log::ger;

use Exporter qw(import);
use Plugin::System (
    hooks => {
        dump => {},
        dump_scalar => {},
        dump_array => {},
        dump_hash => {},
        dump_unknown_ref => {},
    },
);

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT = qw(dd); ## no critic: Modules::ProhibitAutomaticExportation
our @EXPORT_OK = qw(dump);

my %esc = (
    "\a" => "\\a",
    "\b" => "\\b",
    "\t" => "\\t",
    "\n" => "\\n",
    "\f" => "\\f",
    "\r" => "\\r",
    "\e" => "\\e",
);

# from Data::Dump
sub _quote {
    local($_) = $_[0];
    # If there are many '"' we might want to use qq() instead
    s/([\\\"\@\$])/\\$1/g;
    return qq("$_") unless /[^\040-\176]/;  # fast exit

    s/([\a\b\t\n\f\r\e])/$esc{$1}/g;

    # no need for 3 digits in escape for these
    s/([\0-\037])(?!\d)/sprintf('\\%o',ord($1))/eg;

    s/([\0-\037\177-\377])/sprintf('\\x%02X',ord($1))/eg;
    s/([^\040-\176])/sprintf('\\x{%X}',ord($1))/eg;

    return qq("$_");
}

sub _str {
    _quote(shift);
}

sub _scalar {
    my $data = shift;
    defined($data) ? _quote($data) : 'undef';
}

sub dump {
    my $data = shift;

    hook_dump {
        my $ref = ref $data;

        if (!$ref) {
            hook_dump_scalar { _scalar($data) };
        } elsif ($ref eq 'ARRAY') {
            "[" . (hook_dump_array { join(", ", map { &dump($_) } @$data) }) . "]";
        } elsif ($ref eq 'HASH') {
            "{" . (hook_dump_hash  { join(", ", map { _quote($_) . ' => ' . &dump($data->{$_}) } sort keys %$data) }) . "}";
        } else {
            hook_dump_unknown_ref {
                die "Unsupported ref '$ref'";
            };
        }
    };
}

sub dd {
    my $data = shift;
    my $dump = &dump($data);

    print $dump;
    print "\n" unless $dump =~ /\R\z/;

    $data;
}

1;
# ABSTRACT: A simplistic data structure dumper (demo for Plugin::System)

=head1 SYNOPSIS

 use Data::MiniDumpX; # imports dd()

 dd [1, 2, 3]; # prints "[1, 2, 3]"


=head1 DESCRIPTION

This is a simplistic (limited) data structure dumper, meant to be a demo and
testing tool for L<Plugin::System>. See L<Data::DumpX> for the real thing.


=head1 FUNCTIONS

=head2 dump

Usage:

 my $dump = dump($data);

Not exported by default, exportable.

=head2 dd

Usage:

 dd($data); # returns $data


=head1 SEE ALSO

L<Data::DumpX>

L<Plugin::System>

=cut
