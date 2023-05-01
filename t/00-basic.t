#! perl -I. -w
use t::Test::abeltje;

use APIish;
use Test::DBIC::SQLite;

{
    my $t = Test::DBIC::SQLite->new(
        schema_class => 'Perl5::CoreSmokeDB::Schema'
    );
    my $schema = $t->connect_dbic_ok();

    my $smoke_data = read_json('t/data/report1.json');

    my $report = create_full_report($schema, $smoke_data);
    isa_ok($report, 'Perl5::CoreSmokeDB::Schema::Result::Report');

    is(
        $report->arch_os_version_label,
        "arm64 - darwin - 21.6.0 (Mac OS X - macOS 12.5.1 (21G83)) - idefix",
        "->arch_os_version_label"
    );
    is_deeply(
        $report->arch_os_version_pair,
        {
            'label' => 'arm64 - darwin - 21.6.0 (Mac OS X - macOS 12.5.1 (21G83)) - idefix',
            'value' => 'arm64##darwin##21.6.0 (Mac OS X - macOS 12.5.1 (21G83))##idefix'
        },
        "->arch_os_version_pair"
    ) or diag(explain($report->arch_os_version_pair));

    is(
        $report->title,
        "Smoke v5.37.2-448-g03840a1d3f PASS darwin 21.6.0 (Mac OS X - macOS 12.5.1".
        " (21G83)) MacBook Pro (0)  [10 (8 performance and 2 efficiency) cores]",
        "->title"
    );
    is(
        $report->list_title,
        "v5.37.2-448-g03840a1d3f darwin 21.6.0 (Mac OS X - macOS 12.5.1 (21G83))".
        " MacBook Pro (0)  [10 (8 performance and 2 efficiency) cores]",
        "->list_title"
    );

    is($report->duration_in_hhmm, '2 hours 8 minutes', "->duration_in_hhmm");
    is($report->average_in_hhmm, '1 hour 4 minutes', "->average_in_hhmm");
    $schema->storage->disconnect;
    $t->drop_dbic_ok();
}

abeltje_done_testing();
