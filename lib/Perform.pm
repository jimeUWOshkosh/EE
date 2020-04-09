package Perform;

use strict;
use warnings;

BEGIN {
    require Exporter;

    # set the version for version checking
    our $VERSION = 1.00;

    # Inherit from Exporter to export functions and variables
    our @ISA = qw(Exporter);    ## no critic

    # Functions and variables which can be optionally exported
    our @EXPORT_OK = qw($__Perform);
}

# exported package globals go here
our $__Perform;

1;    # don't forget to return a true value from the file
