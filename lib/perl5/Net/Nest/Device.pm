package Net::Nest::Device;

use strict;

use Carp;

sub new {
	my ($class, $self) = @_;

	bless $self, $class;

	return $self;
}

sub set_temperature {
	my ($self, $args) = @_;

	my $temp;

	if ($self->{nest}{units} eq 'C') {
		$temp = $args;
	}
	else {
		$temp = sprintf "%0.1f", ($args - 32.0) / 1.8;
	}

	my $data = sprintf "{\"target_change_pending\":true,\"target_temperature\":%0.1f}", $temp;

	my $url = $self->{nest}{transport_url} . "/v2/put/shared." . $self->{serial};
	
	my $r = new HTTP::Request('POST', $url, $self->{nest}{header}, $data);

	my $response = $self->{nest}{ua}->request($r);

	return ($response->is_success, $response);
}

sub set_fan {
	my ($self, $args) = @_;

	my $data = sprintf '{"fan_mode":"%s"}', $args;

	my $url = $self->{transport_url} . "/v2/put/device." . $self->{serial};
	
	my $r = new HTTP::Request('POST', $url, $self->{nest}{header}, $data);

	my $response = $self->{ua}->request($r);

	return ($response->is_success, $response);
}

sub current_temperature {
	my ($self, $args) = @_;

	my $result = $self->{shared}{current_temperature};

	$result = ($result * 1.8) + 32.0 if $self->{nest}{units} eq 'F';

	return $result;
}

sub target_temperature {
	my ($self, $args) = @_;

	my $result = $self->{shared}{target_temperature};

	$result = ($result * 1.8) + 32.0 if $self->{nest}{units} eq 'F';

	return $result;
}

sub serial {
	my ($self, $args) = @_;

	return $self->{serial};
}

1;

