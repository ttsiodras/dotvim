#!/bin/bash
export PATH=/usr/sbin:$PATH

# Create a small chain for readability (idempotent)
iptables -N RESTRICTED_NET 2>/dev/null || true

# Flush it - remove all that may already exist in there
iptables -F RESTRICTED_NET

# Allow established flows
iptables -A RESTRICTED_NET -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow ONLY the host's Docker IP as a target.
iptables -A RESTRICTED_NET -d 172.17.0.1 -j ACCEPT

# Anything going anywhere else, drop it
iptables -A RESTRICTED_NET -j DROP

# Flush every existing rule in your DOCKER-USER chain
iptables -F DOCKER-USER

# Now attach the RESTRICTED_NET chain to Docker's global pre-container hook
# DOCKER-USER is evaluated for all container traffic.
iptables -I DOCKER-USER -s 172.30.0.0/24 -j RESTRICTED_NET

# Flush every existing rule in your INPUT chain
iptables -F INPUT

# Allow the usual ESTABLISHED/RELATED accept
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Also allow NEW connections from restricted_net ONLY if they target the host's docker I/F: 172.17.0.1
iptables -I INPUT 1 -s 172.30.0.0/24 -d 172.17.0.1 -m conntrack --ctstate NEW -j ACCEPT

# Drop all other NEW traffic from restricted_net to the host (i.e towards any other of the host's IPs)
iptables -I INPUT 2 -s 172.30.0.0/24 -m conntrack --ctstate NEW -j DROP
