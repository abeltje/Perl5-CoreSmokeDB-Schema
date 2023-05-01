package APIish;
use warnings;
use strict;

use Exporter 'import';
our @EXPORT = qw< read_json get_report_data create_full_report >;

use Date::Parse qw( str2time );
use DateTime;
use JSON;

sub read_json {
    my ($filename) = @_;

    if (open(my $fh, '<', $filename)) {
        my $json = do { local $/; <$fh> };
        return from_json($json);
    }
    die "Cannot open($filename): $!";
}

sub get_report_data {
    my ($smoke_data) = @_;

    my $report_data = {
        %{ $smoke_data->{'sysinfo'} },
        sconfig_id => 0,
    };
    $report_data->{lc($_)} = delete $report_data->{$_} for keys %$report_data;
    $report_data->{smoke_date} = DateTime->from_epoch(
        epoch     => str2time($report_data->{smoke_date}),
        time_zone => 'UTC',
    );

    my @to_unarray = qw/
        skipped_tests applied_patches
        compiler_msgs manifest_msgs nonfatal_msgs
    /;
    $report_data->{$_} = join("\n", @{$smoke_data->{$_} || []}) for @to_unarray;

    my @other_data = qw/harness_only harness3opts summary/;
    $report_data->{$_} = $smoke_data->{$_} for @other_data;

    return $report_data;
}

sub create_full_report {
    my ($schema, $smoke_data) = @_;

    my $report_data = get_report_data($smoke_data);
    my $report = $schema->txn_do(
        sub {
            my $r = $schema->resultset('Report')->create($report_data);
            $r->discard_changes;

            for my $config (@{ $smoke_data->{configs}}) {
                my $results = delete($config->{'results'});
                for my $field (qw/cc ccversion/) {
                    $config->{$field} ||= '?';
                }

                $config->{started} = DateTime->from_epoch(
                    epoch     => str2time($config->{started}),
                    time_zone => 'UTC',
                );

                my $conf = $r->create_related('configs', $config);

                for my $result (@$results) {
                    my $failures = delete($result->{'failures'});
                    my $res = $conf->create_related('results', $result);

                    for my $failure (@$failures) {
                        $failure->{'extra'} = join("\n", @{$failure->{'extra'}});
                        my $db_failure = $schema->resultset(
                            'Failure'
                        )->find_or_create(
                            $failure,
                            {key => 'failure_test_status_extra_key'}
                        );
                        $schema->resultset('FailureForEnv')->create(
                            {
                                result_id  => $res->id,
                                failure_id => $db_failure->id,
                            }
                        );
                    }
                }
            }

            return $r;
        }
    );
}
1;
