Perl interface for Nest Thermostat

Inspired by code I saw posted on pastebin, here: http://pastebin.com/M64ErVsF

Sample code:

```perl
#!/usr/bin/env perl

use strict;

use Net::Nest;

my $nest = new Net::Nest({ 
    username => 'user@email.address', 
    password => 'changeme',
    units    => 'F',  # [F]arenheit or [C]elsius              
}); 

foreach my $device (@{ $nest->devices }) {
         
    printf "%s current / target: %0.1f/%0.1f\n", $device->serial, $device->current_temperature, $device->target_temperature;

    # set temperature to 70 degrees farenheit
    $device->set_temperature(70);
}
```
