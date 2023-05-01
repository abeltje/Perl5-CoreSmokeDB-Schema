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

    my $flat_report = $report->as_hashref();
    is_deeply(
        $flat_report,
        {
            applied_patches  => '',
            architecture     => 'arm64',
            compiler_msgs    => '',
            config_count     => 2,
            cpu_count        => ' [10 (8 performance and 2 efficiency) cores]',
            cpu_description  => 'MacBook Pro (0)',
            duration         => 7686,
            git_describe     => 'v5.37.2-448-g03840a1d3f',
            git_id           => '03840a1d3fe4ab4c1bb97279794abab6915b351e',
            harness3opts     => '',
            harness_only     => '0',
            hostname         => 'idefix',
            id               => 1,
            lang             => undef,
            lc_all           => undef,
            log_file         => undef,
            manifest_msgs    => 'MANIFEST did not declare \'.mailmap\'',
            nonfatal_msgs    => '',
            osname           => 'darwin',
            osversion        => '21.6.0 (Mac OS X - macOS 12.5.1 (21G83))',
            out_file         => undef,
            perl_id          => '5.37.4',
            plevel           => '5.037002zzz448',
            reporter         => '',
            reporter_version => '0.054',
            sconfig_id       => 0,
            skipped_tests    => '',
            smoke_branch     => 'blead',
            smoke_date       => '2022-09-06T01:05:04Z',
            smoke_perl       => '5.34.0',
            smoke_revision   => '1.77',
            smoke_version    => '1.77',
            smoker_version   => '0.046',
            summary          => 'PASS',
            test_jobs        => undef,
            user_note        => '',
            username         => 'abeltje'
        },
        "Simple serialisation ->as_hashref()"
    ) or diag(explain($flat_report));
}

abeltje_done_testing();
