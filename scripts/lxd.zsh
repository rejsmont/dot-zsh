# Function for exhanced lxd handling
unset -f lxc 2>/dev/null
lxcbin=$( which lxc 2>/dev/null || true )

if [ "$lxcbin" != "" ]; then
    export LXC_VM='ubuntu-containers'
    function lxc() {
        if [[ $1 == "vm" && `uname -a` != *"Linux"* ]]; then
            if [[ $2 == "start" ]]; then
                VBoxManage startvm $LXC_VM --type headless
            elif [[ $2 == "stop" ]]; then
                VBoxManage controlvm $LXC_VM acpipowerbutton
            elif [[ $2 == "status" ]]; then
                if [[ `VBoxManage list runningvms | grep -c "$LXC_VM"` != "1" ]]; then
                    echo "Virtual machine not running"
                else
                    echo "Virtual machine is running"
                fi
            else
                echo "Usage: lxc vm start|stop|status"
            fi
        elif [[ $1 == "shell" ]]; then
            shift
            lxc exec $@ -- /bin/sh -lc zsh
        elif [[ $1 == "exec" ]]; then
            NEWARGS=()
            shift
            while [ $# -gt 0 ]; do
                case $1 in
                    -t|-t=*|-T|-T=*|-n|-n=*|--debug|--debug=*|--force-local|--force-local=*|--no-alias|--no-alias=*|--verbose|--verbose=*|--mode=*)
                        NEWARGS+=("$1")
                        shift
                        ;;
                    --env)
                        NEWARGS+=("$1")
                        NEWARGS+=("$2")
                        shift
                        shift
                        ;;
                    --)
                        NEWARGS+=("$1")
                        shift
                        break
                        ;;
                    *)
                        NEWARGS+=("$1")
                        LXC_HOST=`echo $1 | cut -s -d: -f 1`
                        if [[ "${LXC_HOST}" == "" ]]; then LXC_HOST=$(lxc remote list | grep '(default) | ' | cut -d ' ' -f 2); fi
                        shift
                        ;;
                esac
            done
            if [[ "x$LXC_HOST" != 'xlocal' ]]; then
                $lxcbin exec --env container_host=${LXC_HOST} ${NEWARGS[@]} $@
            else
                $lxcbin exec ${NEWARGS[@]} $@
            fi
        else
            $lxcbin $@
        fi
    }
fi
