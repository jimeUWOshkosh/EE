Economic Exchange for Everyone Else

run.pl is a sample program ( $ perl run.pl )

The current output is from the Asset modules and 
   the tail end of method PurchaseClones->new_exchange

To see filter output
$ perl -d run.pl

main::(run.pl:6):       my $clone = PurchaseClones->new;
  DB<1> n
main::(run.pl:7):       $clone->purchase_clone;
DB<2> s
list the code of the lib/PurchaseClones.pm your favorite way
DB<3> | l 1-60

