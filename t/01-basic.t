#!perl -T
our $test_count;
use Test::More;
INIT {
    plan tests => $test_count+1;
	use_ok( 'Tie::Hash::Method' );
}


# Setup

tie my %hash, Tie::Hash::Method => FETCH => sub {
    exists $_[0]{hash}{$_[1]} ? $_[0]{hash}{$_[1]} : $_[1]
};

# Basic checks
is($hash{x},'x');
$hash{x}='y';
is($hash{x},'y');
delete $hash{x};
is($hash{x},'x');
BEGIN{ $test_count+=3 };

# Check keys
@hash{qw(a b c d)}=(1..4);
is(join(" ",sort keys %hash),"a b c d");
is(join(" ",sort values %hash),"1 2 3 4");
BEGIN{ $test_count+=2 }

# setup
tie my %f2b, Tie::Hash::Method => STORE => sub {
    (my $v=pop)=~s/foo/bar/g if defined $_[2];
    return $_[0]{hash}{$_[1]}=$v;
};

$f2b{foobar}='foobar';
is($f2b{foobar},'barbar');
BEGIN{ $test_count+=1 }


