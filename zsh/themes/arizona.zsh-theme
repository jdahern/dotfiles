# Based on agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=$'\ue0b0'
PL_BRANCH_CHAR=$'\ue0a0'

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ -n "$SSH_CLIENT" ]]; then
    prompt_segment magenta white "$fg_bold[white]%(!.%{%F{white}%}.)$USER@%m$fg_no_bold[white]"
  else
    prompt_segment yellow magenta "$fg_bold[white]%(!.%{%F{white}%}.)$USER$fg_no_bold[white]"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty git_status
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    bgclr='magenta'
    fgclr='white'
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"

    prompt_segment $bgclr $fgclr

    echo -n "$fg_bold[$fgclr]${ref/refs\/heads\//$PL_BRANCH_CHAR }$fg_no_bold[$fgclr]"

  fi
}

git_super_status() {
  local ref dirty git_status
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    git_status=$(git status --porcelain --branch 2> /dev/null)
    dirty=$(parse_git_dirty)
    bgclr='magenta'
    fgclr='white'
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      clean=' ⚑'
    else
      clean=' ✔'
    fi



    local upstream=$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)
    if [[ -n "${upstream}" && "${upstream}" != "@{upstream}" ]]; then has_upstream=true; fi

    local number_of_untracked_files=$(\grep -c "^??" <<< "${git_status}")
    if [[ $number_of_untracked_files -gt 0 ]]; then untracked=" $number_of_untracked_files☀"; fi

    local number_added=$(\grep -c "^A" <<< "${git_status}")
    if [[ $number_added -gt 0 ]]; then added=" $number_added✚"; fi

    local number_modified=$(\grep -c "^.M" <<< "${git_status}")
    if [[ $number_modified -gt 0 ]]; then
      modified=" $number_modified●"
    fi
    #
    # local number_added_modified=$(\grep -c "^M" <<< "${git_status}")
    # local number_added_renamed=$(\grep -c "^R" <<< "${git_status}")
    # if [[ $number_modified -gt 0 && $number_added_modified -gt 0 ]]; then
    #   modified="$modified$((number_added_modified+number_added_renamed))±"
    # elif [[ $number_added_modified -gt 0 ]]; then
    #   modified=" ●$((number_added_modified+number_added_renamed))±"
    # fi
    #
    local number_deleted=$(\grep -c "^.D" <<< "${git_status}")
    if [[ $number_deleted -gt 0 ]]; then
      deleted=" $number_deleted‒"
      bgclr='red'
      fgclr='white'
    fi

    # local number_added_deleted=$(\grep -c "^D" <<< "${git_status}")
    # if [[ $number_deleted -gt 0 && $number_added_deleted -gt 0 ]]; then
    #   deleted="$deleted$number_added_deleted±"
    # elif [[ $number_added_deleted -gt 0 ]]; then
    #   deleted=" ‒$number_added_deleted±"
    # fi
    #
    #
    # local number_of_stashes="$(git stash list -n1 2> /dev/null | wc -l)"
    # if [[ $number_of_stashes -gt 0 ]]; then
    #   stashed=" $number_of_stashes⚙"
    #   bgclr='magenta'
    #   fgclr='white'
    # fi
    #
    # if [[ $number_added -gt 0 || $number_added_modified -gt 0 || $number_added_deleted -gt 0 ]]; then ready_commit=' ⚑'; fi
    #
    # local upstream_prompt=''
    # if [[ $has_upstream == true ]]; then
    #   commits_diff="$(git log --pretty=oneline --topo-order --left-right ${current_commit_hash}...${upstream} 2> /dev/null)"
    #   commits_ahead=$(\grep -c "^<" <<< "$commits_diff")
    #   commits_behind=$(\grep -c "^>" <<< "$commits_diff")
    #   upstream_prompt="$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)"
    #   upstream_prompt=$(sed -e 's/\/.*$/ ☊ /g' <<< "$upstream_prompt")
    # fi
    #
    # has_diverged=false
    # if [[ $commits_ahead -gt 0 && $commits_behind -gt 0 ]]; then has_diverged=true; fi
    # if [[ $has_diverged == false && $commits_ahead -gt 0 ]]; then
    #   if [[ $bgclr == 'red' || $bgclr == 'magenta' ]] then
    #     to_push=" $fg_bold[white]↑$commits_ahead$fg_bold[$fgclr]"
    #   else
    #     to_push=" $fg_bold[black]↑$commits_ahead$fg_bold[$fgclr]"
    #   fi
    # fi
    # if [[ $has_diverged == false && $commits_behind -gt 0 ]]; then to_pull=" $fg_bold[magenta]↓$commits_behind$fg_bold[$fgclr]"; fi
    #
    # if [[ -e "${repo_path}/BISECT_LOG" ]]; then
    #   mode=" <B>"
    # elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
    #   mode=" >M<"
    # elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
    #   mode=" >R>"
    # fi

    prompt_segment $bgclr $fgclr

    echo -n "$fg_bold[$fgclr]${ref/refs\/heads\//$PL_BRANCH_CHAR $upstream_prompt}${mode}$to_push$to_pull$clean$tagged$stashed$untracked$modified$deleted$added$ready_commit$fg_no_bold[$fgclr]"

  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment blue white "$fg_bold[white]%~$fg_no_bold[white]"
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  echo -n "\n"
  prompt_status
  prompt_dir
  prompt_git
  prompt_end
  CURRENT_BG='NONE'
  echo -n "\n"
  prompt_context
  prompt_end
  CURRENT_BG='NONE'
}

PROMPT='%{%f%b%k%}$(build_prompt)'
