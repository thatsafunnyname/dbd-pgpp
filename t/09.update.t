if (!exists($ENV{PG_TEST_DB}) || !exists($ENV{PG_TEST_USER})) {
	print "1..0 # Skipped: Please set an environment variable require for a test. Refer to README.\n";
	exit 0;
}

use DBI;
use strict;

print "1..4\n";
my $n = 1;

my $pgsql = DBI->connect(
	"dbi:PgPP:dbname=$ENV{PG_TEST_DB};host=$ENV{PG_TEST_HOST}",
	$ENV{PG_TEST_USER}, $ENV{PG_TEST_PASS}, {
		RaiseError => 1,
});
print "ok $n\n"; $n++;

eval {
	my $sth = $pgsql->do(q{UPDATE test SET name='hoge' WHERE id > 1});
};
print "not " if $@ && $pgsql->{affected_rows} != 2;
print "ok $n\n"; $n++;


my $rows = 0;
eval {
	my $sth = $pgsql->prepare(q{
		SELECT id, name FROM test WHERE id > 1 and name='hoge'
	});
	$sth->execute;
	while (my $record = $sth->fetch()) {
		++$rows;
	}
};
print "not " if $@ || $rows != 2;
print "ok $n\n"; $n++;


$pgsql->disconnect;
print "ok $n\n";
