# Function for exhanced lxd handling
lxcbin=`which lxc`

function lxc() {
    if [[ $1 == "vm" && `uname -a` != *"Linux"* ]]; then
        if [[ $2 == "start" ]]; then
            VBoxManage startvm ubuntu-containers --type headless
        elif [[ $2 == "stop" ]]; then
            VBoxManage controlvm ubuntu-containers acpipowerbutton
        elif [[ $2 == "status" ]]; then
            if [[ `VBoxManage list runningvms | grep -c "{0700bb7c-dbb9-4c3f-a41c-663aed50c71e}"` != "1" ]]; then
                echo "Virtual machine not running"
            else
                echo "Virtual machine is running"
            fi
        else
            echo "Usage: lxc vm start|stop|status"
        fi
    elif [[ $1 == "shell" ]]; then
        shift
        lxc exec $@ -- /bin/zsh --login
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
                    HOST=`echo $1 | cut -s -d: -f 1`
                    if [[ "${HOST}" == "" ]]; then HOST="default"; fi
                    shift
                    ;;
            esac
        done
        $lxcbin exec --env CONTAINER_HOST=${HOST} ${NEWARGS[@]} $@
    else
        $lxcbin $@
    fi
}
