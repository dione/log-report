# Copyrights 2007-2012 by [Mark Overmeer].
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 2.00.
use warnings;
use strict;

package Log::Report::Exception;
use vars '$VERSION';
$VERSION = '0.992';


use Log::Report 'log-report';
use POSIX  qw/locale_h/;


use overload '""' => 'toString';


sub new($@)
{   my ($class, %args) = @_;
    $args{report_opts} ||= {};
    bless \%args, $class;
}


sub report_opts() {shift->{report_opts}}


sub reason(;$)
{   my $self = shift;
    @_ ? $self->{reason} = uc(shift) : $self->{reason};
}


sub isFatal() { Log::Report->isFatal(shift->{reason}) }


sub message(;$)
{   my $self = shift;
    @_ or return $self->{message};
    my $msg = shift;
    UNIVERSAL::isa($msg, 'Log::Report::Message')
        or panic __x"message() of exception expects Log::Report::Message";
    $self->{message} = $msg;
}


sub inClass($) { $_[0]->message->inClass($_[1]) }


sub throw(@)
{   my $self    = shift;
    my $opts    = @_ ? { %{$self->{report_opts}}, @_ } : $self->{report_opts};

    my $reason;
    if($reason = delete $opts->{reason})
    {   $opts->{is_fatal} = Log::Report->isFatal($reason)
            unless exists $opts->{is_fatal};
    }
    else
    {   $reason = $self->{reason};
    }

    $opts->{stack} = Log::Report::Dispatcher->collectStack
        if $opts->{stack} && @{$opts->{stack}};

    report $opts, $reason, $self;
}

# where the throw is handled is not interesting
sub PROPAGATE($$) {shift}


sub toString()
{   my $self = shift;
    my $msg  = $self->message;
    lc($self->{reason}) . ': ' . (ref $msg ? $msg->toString : $msg) . "\n";
}


sub print(;$)
{   my $self = shift;
    (shift || *STDERR)->print($self->toString);
}

1;
