package Net::Nest;

use strict;

use Carp;
use Data::Dumper;
use JSON;
use LWP::UserAgent;
use Net::Nest::Device;

sub new {
	my ($class, $args) = @_;

	my $self = {
		units	=> $args->{units} || 'F',
	};

	bless $self, $class;

	$self->{ua} = new LWP::UserAgent;
	$self->{ua}->agent("Nest/1.1.0.10 CFNetwork/548.0.4");
	$self->{baseurl} = "https://home.nest.com";

	$self->_init($args);

	return $self;
}

sub _init {
	my ($self, $args) = @_;

	my $result;

	# login
	my $loginurl = $self->{baseurl} . "/user/login";

	my $response = $self->{ua}->post($loginurl, { username => $args->{username}, password => $args->{password} });

	if (! $response->is_success) {
		croak "failed to log in: $!\n";
	}

	$result = decode_json($response->decoded_content);

	$self->{userid} = $result->{userid};
	$self->{transport_url} = $result->{urls}{transport_url};

	# get status
	my $statusurl = $self->{transport_url} . "/v2/mobile/user." . $self->{userid};

	my $h = new HTTP::Headers();
	$h->header('Authorization' => "Basic " . $result->{access_token});
	$h->header('X-nl-user-id' => $result->{userid});
	$h->header('X-nl-protocol-version' => '1');

	$self->{header} = $h;

	my $r = new HTTP::Request('GET', $statusurl, $h);

	$response = $self->{ua}->request($r);

	if (! $response->is_success) {
		croak "failed to get status: $!\n";
	}
	
	my %devices;

	my $status = decode_json($response->decoded_content);

	foreach my $key (qw/shared device/) {

		foreach my $serial (keys %{$status->{$key}} ) {

			if (! $devices{$serial}) {
				$devices{$serial} = new Net::Nest::Device({ serial => $serial, nest => $self });
			}

			$devices{$serial}->{$key} = $status->{$key}->{$serial};
		}
	}

	$self->{devices} = [ values %devices ];
}
	
sub devices {
	my ($self, $args) = @_;

	return $self->{devices};
}

1;

