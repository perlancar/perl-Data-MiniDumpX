## no critic: TestingAndDebugging::RequireUseStrict
package ScriptX::Run;

use strict;
use Log::ger;

use parent 'ScriptX_Base';

# AUTHORITY
# DATE
# DIST
# VERSION

sub meta {
    return {
        summary => "Run something (code, command) in the 'run' event",
        description => <<'_',

You can give this plugin a coderef (`code`), or a command (`command`). Or you
can also define `run()` in your `main` package.

_
        conf => {
            code => {
                schema => 'code*',
                description => <<'_',

Code will get the plugin's instance as the first argument and stash as the
second:

    ($self, $stash)

_
            },
            command => {
                schema => ['any*', of=>['str*', 'array*']],
                description => <<'_',

Will be run using <pm:IPC::System::Options>'s `system`. Note that you can pass
options to IPC::System::Option via hashref as the first element in the array
argument, for example:

    [{die=>1, log=>1}, 'ls']

_
            },
        },
        conf_rels => {
            choose_one => ['conf', 'command'],
        },
    };
}

sub on_run {
    my ($self, $stash) = @_;

    if (my $code = $self->{code}) {
        log_trace "[ScriptX::Run] Running code";
        $code->($self, $stash);
    } elsif (defined(my $command = $self->{command})) {
        log_trace "[ScriptX::Run] Running command";
        require IPC::System::Options;
        IPC::System::Options::system(
            ref $command eq 'ARRAY' ? @$command : $command);
    } elsif (defined &{"main::run"}) {
        log_trace "[ScriptX::Run] Running main::run()";
        main::run($self, $stash);
    } else {
        die "Don't know what to run. Give me 'code', or 'command', ".
            "or define main::run().";
    }

    [200, "OK"];
}

1;
# ABSTRACT:

=head1 DESCRIPTION
