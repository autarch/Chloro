use strict;
use warnings;

use Test::More 0.88;

use lib 't/lib';

use Chloro::Test::NoNameExtractor;

my $form = Chloro::Test::NoNameExtractor->new();

{
    my $set = $form->process(
        params => {
            foo => 42,
        }
    );

    is_deeply(
        $set->results_as_hash(),
        { foo => 42 },
        'foo is extracted from from form'
    );

    ok(
        !$set->result_for('foo')->has_name_in_form(),
        'foo field has no name in form'
    );
}

done_testing();
