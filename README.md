# NAME

Perl5::CoreSmokeDB::Schema - [DBIC::Schema](https://metacpan.org/pod/DBIx::Class::Schema) for the smoke reports database

# SYNOPSIS

```perl
use Perl5::CoreSmokeDB::Schema;
my $schema = Perl5::CoreSmokeDB::Schema->connect($dsn, $user, $pswd, $options);

my $report = $schema->resultset('Report')->find({ id => 1 });
```
# DESCRIPTION

This class is used in the backend for accessing the database.

Another use is: `$schema->deploy()`

# SCHEMA

This ORM is generated by
[DBIx::Class::Schema::Loader](https://metacpan.org/pod/DBIx::Class::Schema::Loader)
and the `dbicdump` tool it provides (also see
[dbicdump.conf](support/dbicdump.conf)).

Central to the schema are `report`s, they have `config`s. Each `config` has `result`s, and each `result` may have `failures_for_env` that point to a `failure`.

![Perl5::CoreSmokeDB::Schema](support/schema.png)

## SmokeConfig

At the moment this table is not actively used (as the data is not propagated by
[Test::Smoke](https://metacpan.org/pod/Test::Smoke)), but each `report` belongs
to a `smoke_config`.

## Report

This table holds the basic information for a Perl5 core smoke report that is consistent throughout the smoke-run (like OS, hardware, source-tree status and agregate information).

## Config

A `config` consists the arguments passed to `./Configure` the name and version
of the c-compiler.

## Result

This is the aggregate information of a single `make test` run, recording the
value of the `PERLIO` environment variable the summary (`P`/`F`) and the timing
aggregates.

## FailuresForEnv

This is an intermediate table to normalise the many-to-many relationship
between a `result` and a test-`failure`.

## Failure

This table holds the test name, status and output from the test harness.

# AUTHOR

&copy; MMXIII - MMXXII Abe Timmerman <abeltje@cpan.org>, H.Merijn Brand

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

