#!/usr/bin/perl
use strict;
use warnings;

# Maximum allowed handshake age in seconds
my $max_handshake_age = 135;

# Get all WireGuard interface config files
my @wg_configs = glob('/etc/wireguard/wg*.conf');

print "Found ", scalar @wg_configs, " WireGuard interface(s).\n";

foreach my $config (@wg_configs) {
    if ($config =~ m|/etc/wireguard/(wg\d+)\.conf|) {
        my $interface = $1;
        my %endpoints;
        
        print "Processing interface: $interface\n";
        
        # Parse WireGuard configuration file to extract peer endpoints
        open my $fh, '<', $config or die "Cannot open $config: $!";
        my $current_peer;
        while (my $line = <$fh>) {
            chomp $line;
            if ($line =~ /^\[Peer\]/) {
                $current_peer = undef;
            } elsif ($line =~ /^PublicKey = (.+)/) {
                $current_peer = $1;
            } elsif (defined $current_peer && $line =~ /^Endpoint = (.+)/) {
                $endpoints{$current_peer} = $1;
            }
        }
        close $fh;
        
        # Get WireGuard peer status
        my @wg_output = `wg show $interface latest-handshakes`;
        
        foreach my $line (@wg_output) {
            chomp $line;
            my ($peer, $handshake_time) = split /\s+/, $line;
            
            print "Checking peer: $peer\n";
            
            if ($handshake_time eq "(none)") {
                print "Peer $peer on $interface has never handshaked. Restarting...\n";
                if (exists $endpoints{$peer}) {
                    system("wg set $interface peer $peer endpoint $endpoints{$peer}");
                    print "Peer $peer reset successfully.\n";
                } else {
                    print "Endpoint for peer $peer not found in config.\n";
                }
            } else {
                my $elapsed = time - $handshake_time;
                if ($elapsed > $max_handshake_age) {
                    print "Peer $peer on $interface exceeded handshake time ($elapsed s). Restarting...\n";
                    if (exists $endpoints{$peer}) {
                        system("wg set $interface peer $peer endpoint $endpoints{$peer}");
                        print "Peer $peer reset successfully.\n";
                    } else {
                        print "Endpoint for peer $peer not found in config.\n";
                    }
                }
            }
        }
    }
}
