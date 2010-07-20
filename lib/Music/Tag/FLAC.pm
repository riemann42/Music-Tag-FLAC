package Music::Tag::FLAC;
our $VERSION = 0.31;

# Copyright (c) 2007 Edward Allen III. Some rights reserved.
#
## This program is free software; you can redistribute it and/or
## modify it under the terms of the Artistic License, distributed
## with Perl.
#

=pod

=head1 NAME

Music::Tag::FLAC - Plugin module for Music::Tag to get information from flac headers. 

=head1 SYNOPSIS

	use Music::Tag

	my $filename = "/var/lib/music/artist/album/track.flac";

	my $info = Music::Tag->new($filename, { quiet => 1 }, "FLAC");

	$info->get_info();
	   
	print "Artist is ", $info->artist;

=head1 DESCRIPTION

Music::Tag::FLAC is used to read flac header information. It uses Audio::FLAC::Header. 

=head1 REQUIRED VALUES

No values are required (except filename, which is usually provided on object creation). 

=head1 SET VALUES

=cut

use strict;
use Audio::FLAC::Header;

#use Image::Magick;
our @ISA = qw(Music::Tag::Generic);

sub flac {
	my $self = shift;
	unless ((exists $self->{_Flac}) && (ref $self->{_Flac})) {
		if ($self->info->filename) {
			$self->{_Flac} = Audio::FLAC::Header->new($self->info->filename);
		}
	}
	return $self->{_Flac};

}

=over 4

=item title, track, totaltracks, artist, album, comment, releasedate, genre, disc, label

Uses standard tags for these

=item asin

Uses custom tag "ASIN" for this

=item mb_artistid, mb_albumid, mb_trackid, mip_puid, countrycode, albumartist

Uses MusicBrainz recommended tags for these.

=item secs, bitrate

Gathers this info from file.  Please note that secs is fractional.

=cut

our %tagmap = (
	TITLE	=> 'title',
	TRACKNUMBER => 'track',
	TRACKTOTAL => 'totaltracks',
	ARTIST => 'artist',
	ALBUM => 'album',
	COMMENT => 'comment',
	DATE => 'releasedate',
	GENRE => 'genre',
	DISC => 'disc',
	LABEL => 'label',
	ASIN => 'asin',
    MUSICBRAINZ_ARTISTID => 'mb_artistid',
    MUSICBRAINZ_ALBUMID => 'mb_albumid',
    MUSICBRAINZ_TRACKID => 'mb_trackid',
    MUSICBRAINZ_SORTNAME => 'sortname',
    RELEASECOUNTRY => 'countrycode',
    MUSICIP_PUID => 'mip_puid',
    MUSICBRAINZ_ALBUMARTIST => 'albumartist'
);
 
sub get_tag {
    my $self     = shift;
    if ( $self->flac ) {
		while (my ($t, $v) = each %{$self->flac->tags}) {
			if ((exists $tagmap{$t}) && (defined $v)) {
				my $method = $tagmap{$t};
				$self->info->$method($v);
			}
		}
        $self->info->secs( $self->flac->{trackTotalLengthSeconds} );
        $self->info->bitrate( $self->flac->{bitRate} );

=pod

=item picture

This is currently read-only.

=cut

		#"MIME type"     => The MIME Type of the picture encoding
		#"Picture Type"  => What the picture is off.  Usually set to 'Cover (front)'
		#"Description"   => A short description of the picture
		#"_Data"	       => The binary data for the picture.
        if (( $self->flac->picture) && ( not $self->info->picture_exists)) {
			my $pic = $self->flac->picture;
            $self->info->picture( {
					"MIME type" => $pic->{mimeType},
					"Picture Type" => $pic->{description},
					"_Data"	=> $pic->{imageData},
				});
        }
    }
    return $self;
}

sub set_tag {
    my $self = shift;
    if ( $self->flac ) {
		while (my ($t, $v) = each %tagmap) {
			if (defined $self->info->$v) {
				$self->flac->tags->{$t} = $self->info->$v;
			}
		}
        $self->flac->write();
    }
    return $self;
}

sub close {
	my $self = shift;
	delete $self->{_Flac};
}

=back

=head1 OPTIONS

None currently.

=head1 METHODS

=over 4

=item default_options

Returns the default options for the plugin.  

=item set_tag

Save object back to FLAC header.

=item get_tag

Load information from FLAC header.

=item close

Close the file and destroy the Audio::FLAC::Header

=item flac

Returns the Audio::FLAC::Header object

=back

=head1 BUGS

Plugin does not fully support all fields I would like, such as an APIC frame.

=head1 SEE ALSO 

L<Audio::FLAC::Header>, L<Music::Tag>, L<Music::Tag::Amazon>, L<Music::Tag::File>, L<Music::Tag::Lyrics>,
L<Music::Tag::M4A>, L<Music::Tag::MP3>, L<Music::Tag::MusicBrainz>, L<Music::Tag::OGG>, L<Music::Tag::Option>

=head1 AUTHOR 

Edward Allen III <ealleniii _at_ cpan _dot_ org>

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the Artistic License, distributed
with Perl.

=head1 COPYRIGHT

Copyright (c) 2007,2008 Edward Allen III. Some rights reserved.

=cut

1;

# vim: tabstop=4
