package CGI::Application::Standard::Config;
use base 'Exporter';
use vars (qw/@EXPORT $VERSION/);

$VERSION = 1;

# Note: We are loading the config plugin into our callers
# namespace, not our own!
sub import {
  my $class = shift;
  my $app = caller;

  # Export a stub config if  there is not one defined already.
  if (not _meet_config_standard($app) )  {
      push @EXPORT, (qw/config std_config/);
  }
}

sub config { return undef };
sub std_config { return 1 };

sub _meet_config_standard {
    my $app = shift;
    if ( $app->can('config')
          # If they declared they meet the standard, we trust 'em. 
          and $app->can('std_config') ) {
        return 1; 
    }
    else {
        return 0;
    }
}

=pod

Last updated:  Sat Feb 18 23:42:29 EST 2006

=head1 NAME

CGI::Application::Standard::Config -- Define a standard configuration API for CGI::Application

=head1 RATIONALE

This module defines a minimum standard interface that configuration plugins for
CGI::Application should meet.  Having such a standard allows other plugin
authors to rely on basic configuration functionality without coding exceptions
for several configuration modules, or giving up on such integration. 

=head1 SYNOPSIS

=head2 For Average Users

Simply load the config plugin before other modules that might use it: 

  use CGI::Application::Plugin::ConfigAuto;
  use CGI::Application::Plugin::Session;

=head2 For Configuration plugin authors

Configuration plugin authors only need to follow the standards documented below. 

=head2 For other plugin authors who wish to rely on the standard

Plugin authors who want to possibly use this standard can do so by simply
using this module:

  package CGI::Application::Plugin::Session;
  use CGI::Application::Standard::Config;

If a standards complaint config module hasn't already been loaded a stub for
L<config()> will be added which will safely return C<undef>.

=head3 Example use by another plugin

Here code first tries to get configuration details first from a
config file, then from options passed to a plugin-specific config
method, and finally applies defaults if no configuration options are found.

 my $session_options = $self->config('Session_options')
                                      || $self->session_config()
                                      || $self->session_defaults;

=head1 Standard Interface Definition

The following defines a minimum standard for configuration plugins to meet. 

Config plugins are free to provide to additional functionality. 

Configuration plugins are also encourage to explicity document that
they are using C<CGI::Application::Standard::Config>. 

If there are existing methods that follow the standard but have
different names, you can use this example to always export your method:

  sub import {
    my $app = caller;
    no strict 'refs';
    my $full_name = $app . '::config';
    # Change cfg to your config()-compliant method name
    *$full_name = \&cfg;
    CGI::Application::Plugin::YourNameHere->export_to_level(1,@_);
  }

=head2 $self->std_config

This method should be exported by default to simply declare that you  meet the
standard report which version of the standard you meet. This simple
implementation is recommended:

 sub std_config { return 1; }

=head2 $self->config

The intended use is to load to read-only configuration details once
from a config file at start up time.

This service is provided by plugins (list below). They must support at
at least this syntax:

 my $value = $self->config('key');

By default, C<config()> simply returns undef, making it safe for other
plugins to directly to check if C<$self->config('key')> returns the
value it needs.

config() must be exported by default. 

For applications that need little configuration, L<config()> is not
necessary-- using C<PARAMS> in an instance script should suffice.

Also, the C<param()> is the appropriate method to use to set a
configuration value at run time.

Configuration plugins that provide at least this basic API include:

=over 4

=item L<CGI::Application::Plugin::ConfigAuto>.

=back

=cut

=head3 Standard config variables

Users are encouraged to use these standard config variable names, to
ease compatibility between plugins:

 ROOT_URI - A URI corresponding to the project root (http://foo.com/proj )
 ROOT_DIR - a file system path to the same location ( /home/joe/www/proj )

All-caps are used to denote that config variables are essentially global
constants.

Why URI and not URL? The wikipedia explains: 

  The contemporary point of view among the working group that oversees URIs is
  that the terms URL and URN are context-dependent aspects of URI and rarely
  need to be distinguished. Furthermore, the term URL is increasingly becoming
  obsolete, as it is rarely necessary to differentiate between URLs and URIs,
  in general. 

=head1 Standard Version

This is 1.0 of the CGI::Application L<config()> standard.  

=head1 AUTHOR

Written by Mark Stosberg <mark@summersault.com> with input from the
CGI::Application community.  

=cut

1;

