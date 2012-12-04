use strict;
use warnings;
use feature qw/say/;
use utf8;
use Furl;
use JSON;
use IO::File;
use Encode;
use Data::Dumper;


my $base_url = qq|http://api.atnd.org/events/users/?format=json&event_id=|;
my @event_ids = map { chomp; $_ } IO::File->new('events.txt')->getlines;

my $http = Furl->new;
my $json = JSON->new->allow_nonref;

my %users;

for my $event_id (@event_ids) {
    my $json_content = $http->get( $base_url.$event_id )->content;
    my $atnd = $json->decode( $json_content );
    my $hachiojipm = $atnd->{events}[0];
    my $title = encode 'utf8', $hachiojipm->{title};

    for my $user ( @{$hachiojipm->{users}} ) {
        my $nickname = encode 'utf8', $user->{nickname};
        $users{$nickname}{twitter_id} = $user->{twitter_id} || '';
        push @{$users{$nickname}{join}}, $title;
    }
}

for my $nickname ( keys %users ) {
    for my $title ( @{$users{$nickname}{join}} ) {
        say "$nickname,$users{$nickname}{twitter_id},$title";
    }
}

