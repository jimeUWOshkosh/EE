package PurchaseClones;
use feature 'say';
use feature qw(signatures);
no warnings qw(experimental::signatures);    ## no critic
use Moose;
use lib 'lib';
use Tweet;
our $VERSION = '1.00';
use myfilter;
require 'Assets.pl';                         ## no critic

has key => (
    is      => 'rw',
    default => undef,
);

sub new_exchange {
    my ( $slug, $slugtxt, $successmsg, $successmsgtxt,
        $failuresmsg, $failuresmsgtxt, $steps )
      = @_;

    #   say $steps->rc;

    # to work in cohort with $Steps::TESTING
    #
    my $rc = say "\n----output from ", __PACKAGE__,
      "->new_exchange()--------\n\n",
      $steps->trans_mesg;
    #

    return PurchaseClones->new();
}

sub price { my $rc = say "\t\t\tPurchaseClones price"; return 1 }

sub station_area { my $rc = say "\t\t\tPurchaseClones station_area"; return 2 }

sub purchase_clone {
    my ($self) = @_;
    my $rc = say 'purchase_clone2';
    my $character  = Tweet->new( mesg => 'and Irvine' );
    my $bet_amount = 1_000_006;
    my $exchange   = new_exchange(
        slug            => 'purchase-clone',
        success_message => 'You have purchased a new clone',
        failure_message => 'You could not purchase a new clone',
        Steps(
            Location( $self => is_in_area => 'clonevat' ),
            Wallet( $self => pay => $self->price('cloning') ),
            Clone( $self => gestate => $self->station_area ),
            FAILURE( Wallet( $character => remove => $bet_amount ) ),
            ALWAYS( Wallet( $character => 'show_balance' ) ),
        ),
    );
    return;
}

1;
