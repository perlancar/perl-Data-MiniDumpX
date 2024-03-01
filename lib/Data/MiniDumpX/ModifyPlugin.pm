## no critic: TestingAndDebugging::RequireUseStrict
package ScriptX::ModifyPlugin;

# IFUNBUILT
use strict;
use warnings;
# END IFUNBUILT
use Log::ger;

use parent 'ScriptX_Base';

# AUTHORITY
# DATE
# DIST
# VERSION

sub meta {
    return {
        summary => 'Modify the loading (activation) of another plugin',
        conf => {
            plugin => {
                summary => 'Plugin name to be modified',
                schema => 'str*',
                req => 1,
            },
            delete_args => {
                summary => 'List of arguments to delete',
                schema => ['array*', of=>'str*'],
            },
            add_or_modify_args => {
                summary => 'List of arguments to add or modify',
                schema => ['hash*'],
            },
            add_args => {
                summary => 'List of arguments to add (if they were not specified)',
                schema => ['hash*'],
            },
            modify_args => {
                summary => 'List of arguments to modify (if they were specified)',
                schema => ['hash*'],
            },
        },
    };
}

sub before_activate_plugin {
    my ($self, $stash) = @_;

    return [204, "Decline"] unless $stash->{plugin_name} eq $self->{plugin};
    my $args = $stash->{plugin_args};
    if ($self->{add_or_modify_args}) {
        for (keys %{ $self->{add_or_modify_args} }) {
            $args->{$_} = $self->{add_or_modify_args}{$_};
        }
    }
    if ($self->{add_args}) {
        for (keys %{ $self->{add_args} }) {
            $args->{$_} = $self->{add_args}{$_} unless exists $args->{$_};
        }
    }
    if ($self->{modify_args}) {
        for (keys %{ $self->{modify_args} }) {
            $args->{$_} = $self->{modify_args}{$_} if exists $args->{$_};
        }
    }
    if ($self->{delete_args}) {
        for (@{ $self->{delete_args} }) {
            delete $args->{$_};
        }
    }
    [200, "OK"];
}

1;
# ABSTRACT:

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use ScriptX ModifyPlugin => {
     plugin => 'Getopt::Long',
     add_or_modify_args => {
         abort_on_failure => 0,
     },
 };


=head1 DESCRIPTION

This plugin can modify the loading of other plugins, e.g. the arguments passed
to plugin constructor.
