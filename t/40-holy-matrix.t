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

    my @matrix = $report->matrix;
    is(scalar(@matrix), 4 + 1 + 6, "No holes in the matrix")
        or diag(explain([$report->matrix]));
}

abeltje_done_testing();
