package Steps;

#use feature 'say';
#use feature qw(signatures);
#no warnings qw(experimental::signatures);
use Moose;    # Moose brings in strict and warnings
use namespace::autoclean;
use lib 'lib';
use Ouch;
our $VERSION = '1.00';

has 'rc' => (    # Return Code
    is  => 'rw',
    isa => 'Int',
);
has 'trans_mesg' => ( # ErrorLog message about the Economic Exchange transaction
    is  => 'rw',
    isa => 'Str',
);

my @procedures;       # steps to be performed in the Economic Exchange
my @touched;          # logs the steps that have been attempted
our $TESTING = 0;     # for testing Ovid type ErrorLog
my $rs_perform
  ;    # refernce to $Perform::__perform, TRUE to perform/execute step or
       #    FALSE for logging args passed

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my ( $obj, $rc );

    if ( @_ == 1 && !ref $_[0] ) {
        $obj = $class->$orig();
    }
    else {
        $$rs_perform = shift;

        @procedures = @_;
        $rc         = _steps(@procedures);
        while ( my ( $j, $touch ) = each @touched ) { $touched[$j] //= ''; }
        $obj = $class->$orig( rc => $rc, trans_mesg => join( '', @touched ), );
    }

    return $obj;
};

sub BUILD {
    my $self = shift;
    return;
}

sub begin_trans { return 1; }
sub end_trans   { return 1; }
sub roll_back   { return 1; }

sub _steps {
    my (@steps) = @_;
    my $pos1 = 0;
    my ( $obj, $object ); # $obj when things are good, $object when just logging
    $$rs_perform = 1;
    eval {
        begin_trans();
        my $rc = 1;

        # do ASSERTs, always on top
        while ( my ( $j, $step ) = each @steps ) {
            $pos1 = $j;
            last
              if (
                not( ( defined $step->[0] ) and ( $step->[0] eq 'ASSERT' ) ) );
            $obj = $step->[1]();

            # an ASSERT w/ FALSE return code.
            ouch 'No object returned', 'No object returned' if ( not $obj );

            $touched[$pos1] = GiveMeTheBehavior( $step->[0] ) . $obj->arg_text;

            # get out, No more behaviors, create log
            ouch 'Bad ASSERT', 'Bad ASSERT' if ( not( $obj->rc ) );
        }
        my $pos2;

        # do NO or ALWAYS Behaviors
        for my $j ( $pos1 .. $#steps ) {
            $pos2 = $j;
            if (   ( not( defined $steps[$j][0] ) )
                or ( $steps[$j][0] eq 'ALWAYS' ) )
            {
                $obj = $steps[$j][1]();
                ouch 'No object returned', 'No object returned' if ( not $obj );
                $touched[$pos2] =
                  GiveMeTheBehavior( $steps[$j][0] ) . $obj->arg_text;

                # Cleanup, do FAILURE behaviors
                last if ( not( $obj->rc ) );
            }
        }

        # have a FALSE return code
        if ( not( $obj->rc ) ) {

            # hit all FAILUREs, starting where ASSERTs left off
            for my $j ( $pos1 .. $#steps ) {
                next if ( $touched[$j] );
                if (
                    ( defined $steps[$j][0] )
                    and (  ( $steps[$j][1] eq 'FAILURE' )
                        or ( $steps[$j][1] eq 'ALWAYS' ) )
                  )
                {
                    $object = $steps[$j][1]();
                    ouch 'No object returned', 'No object returned'
                      if ( not $object );
                    $touched[$j] =
                      GiveMeTheBehavior( $steps[$j][0] ) . $object->arg_text;

                    # what do you do with a bad return code??
                    ouch 'Bad, Cleanup', 'Bad, Cleanup'
                      if ( not( $object->rc ) );
                }
            }
        }
        if ($TESTING) {

            # FAILURES need to be logged
            $$rs_perform = 0;
            while ( my ( $j, $step ) = each @steps ) {
                next if ( $touched[$j] );
                $object = $step->[1]();
                ouch 'No object returned', 'No object returned'
                  if ( not $object );
                $touched[$j] =
                  GiveMeTheBehavior( $step->[0] ) . $object->arg_text;
            }
            $$rs_perform = 1;
        }
        end_trans();
        1;
    } or do {
        roll_back();
        if ( kiss('Bad ASSERT') or kiss('Bad, Cleanup') ) {

# We need to log the failed Economic Exchange.  No need to check the object's return code
            $$rs_perform = 0;
            eval {
                while ( my ( $j, $step ) = each @steps ) {
                    next if ( $touched[$j] );
                    $object = $step->[1]();
                    ouch 'No object returned', 'No object returned'
                      if ( not $object );
                    $touched[$j] =
                      GiveMeTheBehavior( $step->[0] ) . $object->arg_text;
                }
                1;
            } or do {
                die $@;    ## no critic
            }
        }
        else {
            die $@;        ## no critic                   # rethrow
        }
    };
    return $obj->rc;
}

sub GiveMeTheBehavior {
    my $str = shift;

    # behavior + '('   for the logging output
    return ( defined $str ) ? "$str(" : '';
}

__PACKAGE__->meta->make_immutable;
1;
