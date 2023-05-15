#! perl -I. -w
use t::Test::abeltje;

use APIish;
use Test::DBIC::SQLite;

{
    my $t = Test::DBIC::SQLite->new(
        schema_class => 'Perl5::CoreSmokeDB::Schema'
    );
    my $schema = $t->connect_dbic_ok();

    my $smoke_data = read_json('t/data/i3-cc.jsn');


    my $report = create_full_report($schema, $smoke_data);
    isa_ok($report, 'Perl5::CoreSmokeDB::Schema::Result::Report');

    my $as_hashref = $report->as_hashref('full');
    my $failures0 = $as_hashref->{configs}[0]{results}[0]{failures};
    is_deeply(
        $failures0,
        [
            {
                'failure' => {
                    'extra'  => "44\n92",
                    'id'     => 1,
                    'status' => 'FAILED',
                    'test'   => '../t/io/open.t'
                },
                'failure_id' => 1,
                'result_id'  => 1
            },
            {
                'failure' => {
                    'extra'  => '1701',
                    'id'     => 2,
                    'status' => 'FAILED',
                    'test'   => '../t/op/sprintf2.t'
                },
                'failure_id' => 2,
                'result_id'  => 1
            }
        ],
        "Failing tests"
    ) or diag(explain($failures0));
}

abeltje_done_testing();
