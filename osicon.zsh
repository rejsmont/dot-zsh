function os_detect() {
    local APPLE_ICON=$'\uF179'             # 
    local WINDOWS_ICON=$'\uF17A'           # 
    local FREEBSD_ICON=$'\UF30C '          # 
    local ANDROID_ICON=$'\uF17B'           # 
    local LINUX_ALPINE_ICON=$'\uF300'      # 
    local LINUX_AOSC_ICON=$'\uF301'        # 
    local LINUX_ARCH_ICON=$'\uF303'        # 
    local LINUX_CENTOS_ICON=$'\uF304'      # 
    local LINUX_COREOS_ICON=$'\uF305'      # 
    local LINUX_DEBIAN_ICON=$'\uF306'      # 
    local LINUX_DEVUAN_ICON=$'\uF307'      # 
    local LINUX_ELEMENTARY_ICON=$'\uF309'  # 
    local LINUX_FEDORA_ICON=$'\uF30A'      # 
    local LINUX_GENTOO_ICON=$'\uF30D'      # 
    local LINUX_MAGEIA_ICON=$'\uF310'      # 
    local LINUX_MANDRIVA_ICON=$'\uF311'    # 
    local LINUX_MANJARO_ICON=$'\uF312'     # 
    local LINUX_MINT_ICON=$'\uF30E'        # 
    local LINUX_NIXOS_ICON=$'\uF313'       # 
    local LINUX_OPENSUSE_ICON=$'\uF314'    # 
    local LINUX_RASPBIAN_ICON=$'\uF315'    # 
    local LINUX_REDHAT_ICON=$'\uF316'      # 
    local LINUX_SABAYON_ICON=$'\uF317'     # 
    local LINUX_SLACKWARE_ICON=$'\uF318'   # 
    local LINUX_UBUNTU_ICON=$'\uF31B'      # 
    local LINUX_ICON=$'\uF17C'             # 
    local SUNOS_ICON=$'\uF185 '            # 

    # OS detection
    case $(uname) in
        Darwin)
          OS='OSX'
          OS_ICON=$APPLE_ICON
          ;;
        CYGWIN_NT-*)
          OS='Windows'
          OS_ICON=$WINDOWS_ICON
          ;;
        FreeBSD)
          OS='BSD'
          OS_ICON=$FREEBSD_ICON
          ;;
        OpenBSD)
          OS='BSD'
          OS_ICON=$FREEBSD_ICON
          ;;
        DragonFly)
          OS='BSD'
          OS_ICON=$FREEBSD_ICON
          ;;
        Linux)
          if [[ -f /etc/os-release ]]; then
              os_release_id="$(grep -E '^ID=([a-zA-Z]*)' /etc/os-release | cut -d '=' -f 2)"
          else
              os_release_id="linux"
          fi
          case "$os_release_id" in
            "arch")
            OS='Arch'
            OS_ICON=$LINUX_ARCH_ICON
            ;;
            "alpine")
            OS='Alpine'
            OS_ICON=$LINUX_ALPINE_ICON
            ;;
            "aosc")
            OS='AOSC'
            OS_ICON=$LINUX_AOSC_ICON
            ;;
            "centos")
            OS='CentOS'
            OS_ICON=$LINUX_CENTOS_ICON
            ;;
            "coreos")
            OS='CoreOS'
            OS_ICON=$LINUX_COREOS_ICON
            ;;
            "debian")
            OS='Debian'
            OS_ICON=$LINUX_DEBIAN_ICON
            ;;
            "devuan")
            OS='Devuan'
            OS_ICON=$LINUX_DEVUAN_ICON
            ;;
            "elementary")
            OS='Elementary'
            OS_ICON=$LINUX_ELEMENTARY_ICON
            ;;
            "fedora")
            OS='Fedora'
            OS_ICON=$LINUX_FEDORA_ICON
            ;;
            "gentoo")
            OS='Gentoo'
            OS_ICON=$LINUX_GENTOO_ICON
            ;;
            "mageia")
            OS='Mageia'
            OS_ICON=$LINUX_MAGEIA_ICON
            ;;
            "mandriva")
            OS='Mandriva'
            OS_ICON=$LINUX_MANDRIVA_ICON
            ;;
            "manjaro")
            OS='Manjaro'
            OS_ICON=$LINUX_MANJARO_ICON
            ;;
            "nixos")
            OS='NixOS'
            OS_ICON=$LINUX_NIXOS_ICON
            ;;
            "linuxmint")
            OS='Mint'
            OS_ICON=$LINUX_MINT_ICON
            ;;
            "opensuse"|"tumbleweed")
            OS='OpenSUSE'
            OS_ICON=$LINUX_OPENSUSE_ICON
            ;;
            "raspbian")
            OS='Raspbian'
            OS_ICON=$LINUX_RASPBIAN_ICON
            ;;
            "rhel")
            OS='RedHat'
            OS_ICON=$LINUX_REDHAT_ICON
            ;;
            "sabayon")
            OS='Sabayon'
            OS_ICON=$LINUX_SABAYON_ICON
            ;;
            "slackware")
            OS='Slackware'
            OS_ICON=$LINUX_SLACKWARE_ICON
            ;;
            "ubuntu")
            OS='Ubuntu'
            OS_ICON=$LINUX_UBUNTU_ICON
            ;;
            *)
            OS='Linux'
            OS_ICON=$LINUX_ICON
            ;;
          esac

          # Check if we're running on Android
          case $(uname -o 2>/dev/null) in
            Android)
              OS='Android'
              OS_ICON=$ANDROID_ICON
              ;;
          esac
          ;;
        SunOS)
          OS='Solaris'
          OS_ICON=$SUNOS_ICON
          ;;
        *)
          OS=''
          OS_ICON=''
          ;;
    esac
    export OS
    export OS_ICON
}

os_detect
