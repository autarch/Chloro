use strict;
use warnings;

use Test::More 'no_plan';

{
    package Simple;

    use Chloro;

    field 'foo';
    field 'bar';
}
