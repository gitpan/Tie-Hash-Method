package Tie::Hash::Method;
use strict;
use warnings;
use base 'Exporter';

=head1 NAME

Tie::Hash::Method - Tied hash with specific methods overriden by callbacks

=head1 VERSION

Version 0.01

=cut

our $VERSION= '0.01';
$VERSION= eval $VERSION;    # just in case we have a dev release
our @EXPORT_OK= qw(tie_hash_method);

sub TIEHASH {
    my $class= shift;
    bless { hash => {}, @_ }, $class;
}

sub STORE {
    if ( $_[0]->{STORE} ) {
        return $_[0]->{STORE}->(@_);
    } else {
        return $_[0]->{hash}{ $_[1] }= $_[2];
    }
}

sub FETCH {
    if ( $_[0]->{FETCH} ) {
        return $_[0]->{FETCH}->(@_);
    } else {
        return $_[0]->{hash}{ $_[1] };
    }
}

sub FIRSTKEY {
    if ( $_[0]->{FIRSTKEY} ) {
        return $_[0]->{FIRSTKEY}->(@_);
    } else {

        # reset iterator
        my $val= scalar keys %{ $_[0]{hash} };
        return each %{ $_[0]{hash} };
    }
}

sub NEXTKEY {
    if ( $_[0]->{NEXTKEY} ) {
        return $_[0]->{NEXTKEY}->(@_);
    } else {
        return each %{ $_[0]{hash} };
    }
}

sub EXISTS {
    if ( $_[0]->{EXISTS} ) {
        return $_[0]->{EXISTS}->(@_);
    } else {
        exists $_[0]{hash}->{ $_[1] };
    }
}

sub DELETE {
    if ( $_[0]->{DELETE} ) {
        return $_[0]->{DELETE}->(@_);
    } else {
        delete $_[0]{hash}->{ $_[1] };
    }
}

sub CLEAR {
    if ( $_[0]->{CLEAR} ) {
        return $_[0]->{CLEAR}->(@_);
    } else {
        return %{ $_[0]{hash} }= ();
    }
}

sub SCALAR {
    if ( $_[0]->{NEXTKEY} ) {
        return $_[0]->{NEXTKEY}->(@_);
    } else {
        return scalar %{ $_[0]{hash} };
    }
}

sub methods {
    return grep { $_ ne 'hash' } keys %{ $_[0] };
}

sub hash : lvalue {
    $_[0]{hash};
}

sub tie_hash_method {
    tie my %hash, __PACKAGE__, @_;
    return \%hash;
}

1;    #make require happy

__END__

=head1 SYNOPSIS

    tie my %hash, Tie::Hash::Method => FETCH => sub {
        exists $_[0]{hash}{$_[1]} ? $_[0]{hash}{$_[1]} : $_[1]
    };
    print join "\n", tied(%hash)->methods;
    print Dumper(tied(%hash)->hash);

=head1 DESCRIPTION

Tie::Hash::Method provides a way to create a tied hash with specific
overriden behaviour without having to create a new class to do it. A tied
hash with no methods overriden is functionally equivalent to a normal hash.

Each method in a standard tie can be overriden by providing a callback
to the tie call. So for instance if you wanted a tied hash that changed
'foo' into 'bar' on store you could say:

    tie my %hash, Tie::Hash::Method => STORE => sub {
        (my $v=pop)=~s/foo/bar/g if defined $_[2];
        return $_[0]{hash}{$_[1]}=$v;
    };

The callback is called with exactly the same arguments as the tie itself, in
particular the tied object is always passed as the first argument. The tied object
is itself a hash, which contains a second hash in the "hash" slot which is used
to perform the default operations. The callbacks available are the other keys
in the object. If your code needs to store extra data in the object it should
be stored in the 'pvt' slot of the object. No future release of this module
will ever use or alter anything in that slot.

=head2 CALLBACKS

=over 4

=item STORE this, key, value

Store datum I<value> into I<key> for the tied hash I<this>.

=item FETCH this, key

Retrieve the datum in I<key> for the tied hash I<this>.

=item FIRSTKEY this

Return the first key in the hash.

=item NEXTKEY this, lastkey

Return the next key in the hash.

=item EXISTS this, key

Verify that I<key> exists with the tied hash I<this>.

=item DELETE this, key

Delete the key I<key> from the tied hash I<this>.

=item CLEAR this

Clear all values from the tied hash I<this>.

=item SCALAR this

Returns what evaluating the hash in scalar context yields.

=back

=head2 Methods

=over 4

=item hash

return or sets the underlying hash for this tie.

=item methods

returns a list of methods that are overriden for this tye.

=back

=head2 Exportable Subs

The following subs are exportable on request:

=over 4

=item tie_hash_method(PAIRS)

Returns a reference to a hash tied with the specified
callbacks overriden. Just a short cut.

=back

=head1 AUTHOR

Yves Orton, C<< <yves at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-tie-hash-method at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tie-Hash-Method>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tie::Hash::Method


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tie-Hash-Method>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Tie-Hash-Method>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Tie-Hash-Method>

=item * Search CPAN

L<http://search.cpan.org/dist/Tie-Hash-Method>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Yves Orton, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

