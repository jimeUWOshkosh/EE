use Steps;
use Perform;

use Asset::Area;
sub Area      { return Asset::Area->new(     \$Perlform::__perform, @_); }
use Asset::Clone;
sub Clone     { return Asset::Clone->new(    \$Perlform::__perform, @_); }
use Asset::Event;
sub Event     { return Asset::Event->new(    \$Perlform::__perform, @_); }
use Asset::Inventory;
sub Inventory { return Asset::Inventory->new(\$Perlform::__perform, @_); }
use Asset::Location;
sub Location  { return Asset::Location->new( \$Perlform::__perform, @_); }
use Asset::Stats;
sub Stats     { return Asset::Stats->new(    \$Perlform::__perform, @_); }
use Asset::Wallet;
sub Wallet    { return Asset::Wallet->new(   \$Perlform::__perform, @_); }
1;
