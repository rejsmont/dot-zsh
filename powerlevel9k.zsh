POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=( os_icon host user dir rbenv vcs )
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=( status root_indicator background_jobs )
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=true

POWERLEVEL9K_OS_ICON_BACKGROUND=236
POWERLEVEL9K_HOST_LOCAL_BACKGROUND=166
POWERLEVEL9K_HOST_LOCAL_FOREGROUND=220
POWERLEVEL9K_HOST_REMOTE_BACKGROUND=166
POWERLEVEL9K_HOST_REMOTE_FOREGROUND=220
POWERLEVEL9K_HOST_CONTAINER_BACKGROUND=166
POWERLEVEL9K_HOST_CONTAINER_FOREGROUND=220
POWERLEVEL9K_USER_DEFAULT_BACKGROUND=31
POWERLEVEL9K_USER_DEFAULT_FOREGROUND=15
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND=240
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND=252
POWERLEVEL9K_DIR_HOME_BACKGROUND=240
POWERLEVEL9K_DIR_HOME_FOREGROUND=252
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND=240
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND=252
POWERLEVEL9K_DIR_OTHER_HOME_BACKGROUND=240
POWERLEVEL9K_DIR_OTHER_HOME_FOREGROUND=252
POWERLEVEL9K_DIR_OTHER_HOME_VISUAL_IDENTIFIER_COLOR=9

POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
POWERLEVEL9K_HOME_ICON=''
POWERLEVEL9K_HOME_SUB_ICON=''
POWERLEVEL9K_OTHER_HOME_ICON=''
POWERLEVEL9K_FOLDER_ICON='/'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=6
POWERLEVEL9K_DIR_PATH_SEPARATOR='  '
POWERLEVEL9K_SSH_ICON=''
POWERLEVEL9K_CONTAINER_ICON=''
POWERLEVEL9K_VCS_BRANCH_ICON=' '
POWERLEVEL9K_VCS_GIT_GITHUB_ICON=''
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{$(iterm2_prompt_mark)%}╰─ "

################################################################
# Host: machine (where am I)
set_default POWERLEVEL9K_HOST_TEMPLATE "%m"
prompt_host() {
  local current_state="LOCAL"
  typeset -AH host_state
  if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
    host_state=(
      "STATE"               "REMOTE"
      "CONTENT"             "${POWERLEVEL9K_HOST_TEMPLATE}"
      "BACKGROUND_COLOR"    "${DEFAULT_COLOR}"
      "FOREGROUND_COLOR"    "yellow"
      "VISUAL_IDENTIFIER"   "SSH_ICON"
    )
  elif [[ -n "$CONTAINER_HOST" ]]; then
    host_state=(
      "STATE"               "CONTAINER"
      "CONTENT"             "${CONTAINER_HOST}:${POWERLEVEL9K_HOST_TEMPLATE}"
      "BACKGROUND_COLOR"    "${DEFAULT_COLOR}"
      "FOREGROUND_COLOR"    "yellow"
      "VISUAL_IDENTIFIER"   "CONTAINER_ICON"
    )
  elif [[ "$POWERLEVEL9K_SHOW_LOCAL" == true ]]; then
    host_state=(
      "STATE"               "LOCAL"
      "CONTENT"             "${POWERLEVEL9K_HOST_TEMPLATE}"
      "BACKGROUND_COLOR"    "${DEFAULT_COLOR}"
      "FOREGROUND_COLOR"    "011"
      "VISUAL_IDENTIFIER"   "HOST_ICON"
    )
  else
    return
  fi
  "$1_prompt_segment" "$0_${host_state[STATE]}" "$2" "${host_state[BACKGROUND_COLOR]}" "${host_state[FOREGROUND_COLOR]}" "${host_state[CONTENT]}" "${host_state[VISUAL_IDENTIFIER]}"
}

# Dir: current working directory
set_default POWERLEVEL9K_DIR_PATH_SEPARATOR "/"
set_default POWERLEVEL9K_HOME_FOLDER_ABBREVIATION "~"
set_default POWERLEVEL9K_DIR_SHOW_WRITABLE false
prompt_dir() {
  local tmp="$IFS"
  local IFS=""
  local current_path=$(pwd | sed -e "s,^$HOME,~,")
  local IFS="$tmp"
  if [[ -n "$POWERLEVEL9K_SHORTEN_DIR_LENGTH" || "$POWERLEVEL9K_SHORTEN_STRATEGY" == "truncate_with_folder_marker" ]]; then
    set_default POWERLEVEL9K_SHORTEN_DELIMITER $'\U2026'

    case "$POWERLEVEL9K_SHORTEN_STRATEGY" in
      truncate_middle)
        current_path=$(pwd | sed -e "s,^$HOME,~," | sed $SED_EXTENDED_REGEX_PARAMETER "s/([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})[^/]+([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})\//\1$POWERLEVEL9K_SHORTEN_DELIMITER\2\//g")
      ;;
      truncate_from_right)
        current_path=$(truncatePathFromRight "$(pwd | sed -e "s,^$HOME,~,")" )
      ;;
      truncate_with_package_name)
        local name repo_path package_path current_dir zero

        # Get the path of the Git repo, which should have the package.json file
        if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == "true" ]]; then
          # Get path from the root of the git repository to the current dir
          local gitPath=$(git rev-parse --show-prefix)
          # Remove trailing slash from git path, so that we can
          # remove that git path from the pwd.
          gitPath=${gitPath%/}
          package_path=${$(pwd)%%$gitPath}
          # Remove trailing slash
          package_path=${package_path%/}
        elif [[ $(git rev-parse --is-inside-git-dir 2> /dev/null) == "true" ]]; then
          package_path=${$(pwd)%%/.git*}
        fi

        # Replace the shortest possible match of the marked folder from
        # the current path. Remove the amount of characters up to the
        # folder marker from the left. Count only the visible characters
        # in the path (this is done by the "zero" pattern; see
        # http://stackoverflow.com/a/40855342/5586433).
        local zero='%([BSUbfksu]|([FB]|){*})'
        current_dir=$(pwd)
        # Then, find the length of the package_path string, and save the
        # subdirectory path as a substring of the current directory's path from 0
        # to the length of the package path's string
        subdirectory_path=$(truncatePathFromRight "${current_dir:${#${(S%%)package_path//$~zero/}}}")
        # Parse the 'name' from the package.json; if there are any problems, just
        # print the file path
        defined POWERLEVEL9K_DIR_PACKAGE_FILES || POWERLEVEL9K_DIR_PACKAGE_FILES=(package.json composer.json)

        local pkgFile="unknown"
        for file in "${POWERLEVEL9K_DIR_PACKAGE_FILES[@]}"; do
          if [[ -f "${package_path}/${file}" ]]; then
            pkgFile="${package_path}/${file}"
            break;
          fi
        done

        local packageName=$(jq '.name' ${pkgFile} 2> /dev/null \
          || node -e 'console.log(require(process.argv[1]).name);' ${pkgFile} 2>/dev/null \
          || cat "${pkgFile}" 2> /dev/null | grep -m 1 "\"name\"" | awk -F ':' '{print $2}' | awk -F '"' '{print $2}' 2>/dev/null \
          )
        if [[ -n "${packageName}" ]]; then
          # Instead of printing out the full path, print out the name of the package
          # from the package.json and append the current subdirectory
          current_path="`echo $packageName | tr -d '"'`$subdirectory_path"
        else
          current_path=$(truncatePathFromRight "$(pwd | sed -e "s,^$HOME,~,")" )
        fi
      ;;
      truncate_with_folder_marker)
        local last_marked_folder marked_folder
        set_default POWERLEVEL9K_SHORTEN_FOLDER_MARKER ".shorten_folder_marker"

        # Search for the folder marker in the parent directories and
        # buildup a pattern that is removed from the current path
        # later on.
        for marked_folder in $(upsearch $POWERLEVEL9K_SHORTEN_FOLDER_MARKER); do
          if [[ "$marked_folder" == "/" ]]; then
            # If we reached root folder, stop upsearch.
            current_path="/"
          elif [[ "$marked_folder" == "$HOME" ]]; then
            # If we reached home folder, stop upsearch.
            current_path="~"
          elif [[ "${marked_folder%/*}" == $last_marked_folder ]]; then
            current_path="${current_path%/}/${marked_folder##*/}"
          else
            current_path="${current_path%/}/$POWERLEVEL9K_SHORTEN_DELIMITER/${marked_folder##*/}"
          fi
          last_marked_folder=$marked_folder
        done

        # Replace the shortest possible match of the marked folder from
        # the current path.
        current_path=$current_path${PWD#${last_marked_folder}*}
      ;;
      truncate_to_unique)
        # for each parent path component find the shortest unique beginning
        # characters sequence. Source: https://stackoverflow.com/a/45336078
        paths=(${(s:/:)PWD})
        cur_path='/'
        cur_short_path='/'
        for directory in ${paths[@]}
        do
          cur_dir=''
          for (( i=0; i<${#directory}; i++ )); do
            cur_dir+="${directory:$i:1}"
            matching=("$cur_path"/"$cur_dir"*/)
            if [[ ${#matching[@]} -eq 1 ]]; then
              break
            fi
          done
          cur_short_path+="$cur_dir/"
          cur_path+="$directory/"
        done
        current_path="${cur_short_path: : -1}"
      ;;
      *)
        current_path="$(print -P "%$((POWERLEVEL9K_SHORTEN_DIR_LENGTH+1))(c:$POWERLEVEL9K_SHORTEN_DELIMITER/:)%${POWERLEVEL9K_SHORTEN_DIR_LENGTH}c")"
      ;;
    esac
  fi

  if [[ "${POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER}" == "true" ]]; then
    local current_path_first="${current_path[1,1]}"
    current_path="${current_path[2,-1]}"
  fi

  if [[ "${POWERLEVEL9K_DIR_PATH_SEPARATOR}" != "/" ]]; then
    if [[ "${POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER}" == "true" && ${current_path} != "" && ${current_path_first} != "~" ]]; then
        current_path="/${current_path}"
    fi
    current_path="$( echo "${current_path}" | sed "s/\//${POWERLEVEL9K_DIR_PATH_SEPARATOR}/g" | sed "s/^ *//")"
  fi

  if [[ "${POWERLEVEL9K_HOME_FOLDER_ABBREVIATION}" != "~" ]]; then
    current_path=${current_path/#\~/${POWERLEVEL9K_HOME_FOLDER_ABBREVIATION}}
  fi

  typeset -AH dir_states
  dir_states=(
    "DEFAULT"            "FOLDER_ICON"
    "HOME"               "HOME_ICON"
    "HOME_SUBFOLDER"     "HOME_SUB_ICON"
    "OTHER_HOME"         "OTHER_HOME_ICON"
    "DEFAULT_RO"         "FOLDER_ICON"
    "HOME_RO"            "HOME_ICON"
    "HOME_SUBFOLDER_RO"  "HOME_SUB_ICON"
    "OTHER_HOME_RO"      "OTHER_HOME_ICON"
  )
  local current_state="DEFAULT"
  if [[ $(print -P "%~") == '~' ]]; then
    current_state="HOME"
  elif [[ $(print -P "%~") == '~/'* ]]; then
    current_state="HOME_SUBFOLDER"
  elif [[ $(print -P "%~") == '~'* ]]; then
    current_state="OTHER_HOME"
  fi
  if [[ "${POWERLEVEL9K_DIR_SHOW_WRITABLE}" == true && ! -w "$PWD" ]]; then
    current_state="${current_state}_RO"
  fi

  "$1_prompt_segment" "$0_${current_state}" "$2" "blue" "$DEFAULT_COLOR" "${current_path}" "${dir_states[$current_state]}"
}
