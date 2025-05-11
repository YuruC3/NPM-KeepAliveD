# Nginx-Proxy-Manager-KeepAliveD
KeepAliveD with NPM for a HA "cluster".

In short, it is a simple failover using a KAD with a VIP on DMZ. 

This repo assumes that you have 3 nodes. If you have 2 nodes then do not include VM-3 file and edit .conf files so that you only have one unicast_peer. 

If you have more than 3 nodes then copy KPAVD-VM-3.conf and edit it 

At the bottom I've written some examples on how to divide traffic for better security.

I'll be maybe developing it further on my own [gitea](https://tea.shupogaki.org/YuruC3/NPM-KeepAliveD) cuz it feels nicer to use than Github.

## Requirements
Docker

KeepAliveD

Access to internet

Docker Healthcheck configured with NPM container. Check file |docker-compose.yml| for an example.


## Installation and editing configs

Download repo as zip or clone it. 

Place KPAVD-VM-<> in /etc/keepalived/

Change <KAD_NET> to an interface where KAD on nodes will communicate.

Then edit <MASTER_NODE_IP> in the KPAVD-VM-1.conf and <NODE_IP> in the rest of the .conf files. 

After that edit <BACKUP_NODE_IP> in all three config files and/or add more if needed.. Remember to not include |unicast_src_ip| in the |unicast_peer| list.

Change VIP under |virtual_ipaddress| so that it should resemble 192.168.1.5/24 dev enp1s0. If you do plan to have Virtual IP on different NIC then remove |dev <DMZ_NIC>|, allthough I think it is better to set it on a specific interface. Then you will not wake up one day to see VIP on a random interface.

Place the |check_docker_container.sh| in your preferable folder. I suggest placing it together with config file. After that edit path after |script| so that it would point to the script. Lastly change <name_of_your_container> to one that your NPM container has. 

Lastly edit <CHANGE_TO_8-CHARACTER_PASSWORD>. Note that it should be 8-characters long.

After everything mentioned above restart keepalived service and it should work.

## Short config explanation

For more indept explanation [here](https://www.keepalived.org/manpage.html) is official documentation for KeepAliveD

### vrrp_script

interval 5 -- Runs script every 5 seconds. It means that downtime should be for about 5 seconds. You can tweak it to a lower number but then set rise to a higher number.

fall 1 -- Number of times after which a node is put into FAULT STATE. Can be set to 0 or removed completely.

rise 30 -- After 30 succesfull runs node is put into MASTER/BACKUP STATE. It is set to 30 as I need to wait around 150 for NPM to route traffic again. If it comes back faster for you then it can be lowered from 30.

### vrrp_instance

virtual_router_id -- ID of VRRP instance. All nodes need to have the same id.

priority -- Priority of a particular node. Higher priority means that a node will be a MASTER node before ones with lower prioruty

## Example bare-minimum setup
VLAN10-DMZ -- Here will the VIP be. Configure ACLs so that this would be accessible from your preferred VLANs.

VLAN20-Internal -- Network that should not have any open ports. It also needs to have access to internet in order to download KAD, Docker, etc.

## More secure setup
VLAN30-SSH-MGT -- It is used for SSHing into nodes. The purpose of creating it is to setup sshd_config to only respond to address set on that vlan.

VLAN50-KPAVD -- Fully enclosed network. Preferably without access to a gateway. It is only for communication between nodes.

Also set up UFW or iptables.
