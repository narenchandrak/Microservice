# Installation & Configuring DNS

Install and Configure Bind DNS to resolve hostnames and Cloud Applications names which you will deploy in Openshift Platform.

##### Step 1: Install Bind Packages:

```bash
# yum install bind* -y
```

##### Step 2: Configure Bind:

```bash
# cp /etc/named.conf /etc/named.conf.bck

# vim /etc/named.conf
```

```
	#do the following changes:
	listen-on port 53 { 127.0.0.1; 192.168.122.11; };
	allow-query     { any };
	
	zone "lab.example.com" IN {
                type master;
                file "forward.lab.example.com";
                allow-update { none; };
    };
    
    zone "122.168.192.in-addr.arpa" IN {
                type master;
                file "reverse.lab.example.com";
                allow-update { none; };
    };
```

```bash
# vim /var/named/forward.lab.example.com
```

```
$TTL 86400
@   IN  SOA     master.lab.example.com. root.lab.example.com. (
        2011071001  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)

; name servers - NS records (Pointing to the Master Node hostname A record below)
@       IN  NS          master.lab.example.com.

master                 IN  A   192.168.122.11
worker1                IN  A   192.168.122.12
worker2                IN  A   192.168.122.13
infra1                 IN  A   192.168.122.14
@                      IN  A   192.168.122.11
```

```bash
# vim /var/named/reverse.lab.example.com
```

```
$TTL 86400
@   IN  SOA     master.lab.example.com. root.lab.example.com. (
        2011071001  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)

; name servers - NS records (Pointing to the master hostname in forwad.lab.example.com)
@       IN  NS          master.lab.example.com.
master  IN  A           192.168.122.11
; 192.168.1.0/24 - PTR Records
11      IN  PTR         master.lab.example.com.
12      IN  PTR         worker1.lab.example.com.
13      IN  PTR         worker2.lab.example.com.
14      IN  PTR         infra1.lab.example.com.
```

##### Step 3: Start the DNS Service:

Configuring Permissions, Ownership, and SELinux

```bash
# chgrp named -R /var/named
# chown -v root:named /etc/named.conf
# restorecon -rv /var/named
# restorecon /etc/named.conf
```

Enable Port for the DNS

```bash
# firewall-cmd --permanent --add-port=53/tcp
# firewall-cmd --permanent --add-port=53/udp
# firewall-cmd --reload
```

Start and Enable DNS Service

```bash
# systemctl enable named && systemctl start named && systemctl status named
```

Test DNS configuration and zone files for any syntax errors

```bash
# named-checkconf /etc/named.conf
# named-checkzone lab.example.com /var/named/forward.lab.example.com
# named-checkzone lab.example.com /var/named/reverse.lab.example.com
```

##### Step 4: Added the DNS Server IP Address in all Nodes

```shell
# vim /etc/reslove.conf
	nameserver 192.168.122.11
# chattr + /etc/reslove.conf
# Vim /etc/sysconfig/network-scripts/ifcfg-eth0
	peerdns=no
```