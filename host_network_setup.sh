vboxmanage () { VBoxManage.exe "$@"; }
vboxmanage natnetwork add --netname sys_net_prov --network 192.168.254.0/24 --dhcp off 

vboxmanage natnetwork modify  --netname sys_net_prov --port-forward-4 "rule1:TCP:[]:50022:[192.168.254.10]:22"
vboxmanage natnetwork modify  --netname sys_net_prov --port-forward-4 "rule2:TCP:[]:50080:[192.168.254.10]:80"
vboxmanage natnetwork modify  --netname sys_net_prov --port-forward-4 "rule3:TCP:[]:50443:[192.168.254.10]:443"


