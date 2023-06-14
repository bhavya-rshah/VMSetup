vboxmanage () { VBoxManage.exe "$@"; }
# get the abosolute path of the current script 
declare script_path="$(readlink -f $0)"

# get the path of its enclosing directory us this to setup relative paths
declare script_dir=$(dirname "${script_path}")
vboxmanage createvm --name WpVm --register;
# Cludge to get the path of the directory where the vbox file is stored. 
# Used to create hard disk file in same directory as vbox file without using 
# absolute paths

# You will need to change the VM name to match one of your VM's
declare vm_name="WpVm"

# vboxmanage showvminfo displays line with the path to the config file -> grep "Config file returns it
declare vm_info="$(VBoxManage.exe showvminfo "${vm_name}")"
declare vm_conf_line="$(echo "${vm_info}" | grep "Config file")"

# Windows: the extended regex [[:alpha:]]:(\\[^\]+){1,}\\.+\.vbox matches everything that is a path 
# i.e. C:\ followed by anything not a \ and then repetitions of that ending in a filename with .vbox extension
declare vm_conf_file="$( echo "${vm_conf_line}" | grep -oE '[[:alpha:]]:(\\[^\]+){1,}\\.+\.vbox' )"

# strip leading text and trailing filename from config file line to leave directory of VM
declare vm_directory_win="$(echo ${vm_conf_file} | sed 's/Config file:\s\+// ; s/\\[^\]\+\.vbox$//')"

# Strip leading text from the config file line and convert from windows path to wsl linux path 
declare vm_directory_linux="$(echo ${vm_conf_file} | sed 's/Config file:\s\+// ; s/\([[:upper:]]\):/\/mnt\/\L\1/ ; s/\\/\//g')"

# Remove file part of path leaving directory
vm_directory_linux="$(dirname "$vm_directory_linux")"

# WSL commands will use the linux path, whereas Windows native commands (most
# importantly VBoxManage.exe) will use the windows style path.
echo "${vm_directory_linux}"
echo "${vm_directory_win}"

vboxmanage createhd --filename "${vm_directory_win}/${vm_name}.vdi" \
                    --size 10000 -variant Standard



vboxmanage storagectl ${vm_name} --name ide --add ide --bootable on
vboxmanage storagectl ${vm_name} --name sata --add sata --bootable on

vboxmanage storageattach ${vm_name} \
            --storagectl ide \
            --port 0 \
            --device 0 \
            --type dvddrive \
            --medium "../../CentOS-7-x86_64-Minimal-1810.iso"

vboxmanage storageattach ${vm_name} \
            --storagectl ide \
            --port 1 \
            --device 0 \
            --type dvddrive \
            --medium "C:\Program Files\Oracle\VirtualBox\VBoxGuestAdditions.iso"


vboxmanage storageattach ${vm_name} \
            --storagectl sata \
            --port 0 \
            --device 0 \
            --type hdd \
            --medium "${vm_directory_win}/${vm_name}.vdi" \
            --nonrotational on



vboxmanage modifyvm ${vm_name}\
            --groups "${group_name}"\
            --ostype "RedHat_64"\
            --cpus 1\
            --hwvirtex on\
            --nestedpaging on\
            --largepages on\
            --firmware bios\
            --nic1 natnetwork\
            --nat-network1 sys_net_prov\
            --cableconnected1 on\
            --audio none\
            --boot1 disk\
            --boot2 dvd\
            --boot3 none\
            --boot4 none\
            --memory 1280

#vboxmanage startvm ${vm_name} --type gui

