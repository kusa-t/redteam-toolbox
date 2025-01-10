# Network

## ligolo-ng

### Setup

linux proxy
```bash
sudo ip tuntap add user root mode tun ligolo
sudo ip link set ligolo up
sudo ./proxy -selfcert -laddr 0.0.0.0:9001
```

linux agent (root preferable)
```
./agent -connect 192.168.1.1:9001 -ignore-cert -retry
```

windows agent
```cmd
.\agent.exe -connect 192.168.1.1:9001 -ignore-cert -retry
```

### Session
```ligolo-ng
session
ifconfig
```

add route
```bash
route_add --name ligolo --route 172.16.1.0/24
```

```
tunnel_start
```
### Listener
start
```ligolo-ng
listener_add --addr 0.0.0.0:10080 --to 127.0.0.1:80 --tcp
listener_add --addr 0.0.0.0:10443 --to 127.0.0.1:443 --tcp
listener_add --addr 0.0.0.0:19001 --to 127.0.0.1:9001 --tcp
```

stop
```ligolo-ng
listener_list
listener_stop
```


### Cleanup
remove tuntap
```
sudo ip tuntap del mode tun ligolo
```