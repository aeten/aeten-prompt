SORG=$PS1;

if [ -n "${BASH_VERSION}" ]; then

	source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/base.sh"

	if [ -z "$SSH_CLIENT" ]; then
		: ${aeten_prompt_config_file=$(for prefix in /etc/ ~/. ~/.config/ ~/.etc/ ~/.dotfiles/; do echo ${prefix}aeten-prompt; done)}
		for omg_config_file in ${aeten_prompt_config_file}; do
			[ -f ${omg_config_file} ] && . ${omg_config_file}
		done
	fi

	# Fallback US-ASCII symbols
	: ${omg_is_a_git_repo_symbol:=git}            #    
	: ${omg_has_untracked_files_symbol:=?}        #                ?    
	: ${omg_has_adds_symbol:=+}                   #  
	: ${omg_has_deletions_symbol:=-}              #  
	: ${omg_has_cached_deletions_symbol:=X}       #  
	: ${omg_has_modifications_symbol:=E}          #  
	: ${omg_has_cached_modifications_symbol:=C}   #  
	: ${omg_ready_to_commit_symbol:=R}            #   →
	: ${omg_is_on_a_tag_symbol:=L}                #   
	: ${omg_needs_to_merge_symbol:=M}             # ᄉ 
	: ${omg_detached_symbol:=D}
	: ${omg_can_fast_forward_symbol:=F}           #   
	: ${omg_has_diverged_symbol:=Y}               #   
	: ${omg_not_tracked_branch_symbol:=U}
	: ${omg_rebase_tracking_branch_symbol:=B}     #      not 
	: ${omg_merge_tracking_branch_symbol:=T}      #  
	: ${omg_should_push_symbol:=P}                #    
	: ${omg_has_stashes_symbol:=S}
	: ${omg_arrow:=>}                             # 
	: ${omg_separator:=>}                         # 

	: ${omg_theme=green}
	: ${omg_theme_variant=} #dark
	: ${omg_bold='\e[1m'}
	: ${omg_normal='\e[0m'}

	: ${omg_blue='31'}
	: ${omg_dark_blue='24'}
	: ${omg_green='29'}
	: ${omg_dark_green='23'}
	: ${omg_gray='250'}
	: ${omg_medium_gray='245'}
	: ${omg_dark_gray='240'}
	: ${omg_white='231'}

	# foreground
	: ${omg_fg_blue="\e[38;5;${omg_blue}m"}
	: ${omg_fg_darkblue="\e[38;5;${omg_dark_blue}m"}
	: ${omg_fg_green="\e[38;5;${omg_green}m"}
	: ${omg_fg_darkgreen="\e[38;5;${omg_dark_green}m"}
	: ${omg_fg_gray="\e[38;5;${omg_gray}m"}
	: ${omg_fg_mediumgray="\e[38;5;${omg_medium_gray}m"}
	: ${omg_fg_darkgray="\e[38;5;${omg_dark_gray}m"}
	: ${omg_fg_white="\e[38;5;${omg_white}m"}

	#background
	: ${omg_bg_blue="\e[48;5;${omg_blue}m"}
	: ${omg_bg_darkblue="\e[48;5;${omg_dark_blue}m"}
	: ${omg_bg_green="\e[48;5;${omg_green}m"}
	: ${omg_bg_darkgreen="\e[48;5;${omg_dark_green}m"}
	: ${omg_bg_gray="\e[48;5;${omg_gray}m"}
	: ${omg_bg_mediumgray="\e[48;5;${omg_medium_gray}m"}
	: ${omg_bg_darkgray="\e[48;5;${omg_dark_gray}m"}
	: ${omg_bg_white="\e[48;5;${omg_white}m"}

	: ${omg_fg_theme=omg_fg_${omg_theme_variant}${omg_theme}}
	: ${omg_bg_theme=omg_bg_${omg_theme_variant}${omg_theme}}

	# Text Reset
	: ${omg_reset='\[\e[0m\]'}

	PROMPT='$(build_prompt)'
	RPROMPT='%{$reset_color%}%T %{$fg_bold[white]%} %n@%m%{$reset_color%}'

	function enrich_append {
		local flag=${1}
		local symbol=${2}
		local color=${3}
		if [ "${flag}" = false ]; then symbol=''; fi
		[ -z "${symbol}" ] || symbol+=' '

		echo -n "${color}${symbol}"
	}

	function custom_build_prompt {
		local enabled=${1}
		local current_commit_hash=${2}
		local is_a_git_repo=${3}
		local current_branch=$4
		local detached=${5}
		local just_init=${6}
		local has_upstream=${7}
		local has_modifications=${8}
		local has_modifications_cached=${9}
		local has_adds=${10}
		local has_deletions=${11}
		local has_deletions_cached=${12}
		local has_untracked_files=${13}
		local ready_to_commit=${14}
		local tag_at_current_commit=${15}
		local is_on_a_tag=${16}
		local has_upstream=${17}
		local commits_ahead=${18}
		local commits_behind=${19}
		local has_diverged=${20}
		local should_push=${21}
		local will_rebase=${22}
		local has_stashes=${23}

		local prompt=""
		local original_prompt=$PS1

		local user_color="\[${omg_bold}${omg_fg_white}${!omg_bg_theme}\]"
		local user_to_path_color="\[${omg_bold}${!omg_fg_theme}${omg_bg_darkgray}\]"
		local path_color="\[${omg_normal}${omg_fg_gray}${omg_bg_darkgray}\]"
		local path_separator_color="\[${omg_normal}${omg_fg_mediumgray}${omg_bg_darkgray}\]"
		local path_color_last="\[${omg_bold}${omg_fg_gray}${omg_bg_darkgray}\]"
		local path_color_highlight="\[${omg_bold}${omg_fg_white}${omg_bg_darkgray}\]"
		local path_end_color="\[${omg_bold}${omg_fg_darkgray}\]"
		local vcs_color="\[${omg_normal}${omg_fg_white}${!omg_bg_theme}\]"
		local vcs_color_arrow="\[${omg_normal}${omg_fg_white}${!omg_bg_theme}\]"
		local vcs_to_path_color="\[${omg_bold}${!omg_fg_theme}${omg_bg_darkgray}\]"

		local top_level
		local color
		local arrow
		local path=$(pwd)
		local last_rep=$(basename ${path})

		if [ "$is_a_git_repo" = true ]; then
			# on filesystem
			prompt="${vcs_color} "
			prompt+=$(enrich_append $is_a_git_repo $omg_is_a_git_repo_symbol "${vcs_color}")
			prompt+=$(enrich_append $has_stashes $omg_has_stashes_symbol "${vcs_color}")

			prompt+=$(enrich_append $has_untracked_files $omg_has_untracked_files_symbol "${vcs_color}")
			prompt+=$(enrich_append $has_modifications $omg_has_modifications_symbol "${vcs_color}")
			prompt+=$(enrich_append $has_deletions $omg_has_deletions_symbol "${vcs_color}")

			# ready
			prompt+=$(enrich_append $has_adds $omg_has_adds_symbol "${vcs_color}")
			prompt+=$(enrich_append $has_modifications_cached $omg_has_cached_modifications_symbol "${vcs_color}")
			prompt+=$(enrich_append $has_deletions_cached $omg_has_cached_deletions_symbol "${vcs_color}")
			# next operation

			prompt+=$(enrich_append $ready_to_commit $omg_ready_to_commit_symbol "${vcs_color}")

			# where
			prompt+=" ${vcs_color}"
			if [ "$detached" = true ]; then
				prompt+=$(enrich_append $detached $omg_detached_symbol "${vcs_color}")
				prompt+=$(enrich_append $detached "(${current_commit_hash:0:7})" "${vcs_color}")
			else            
				if [ "$has_upstream" = false ]; then
					prompt+=$(enrich_append true "${omg_not_tracked_branch_symbol} (${current_branch})" "${vcs_color}")
				else
					if [ "$will_rebase" = true ]; then
						local type_of_upstream=$omg_rebase_tracking_branch_symbol
					else
						local type_of_upstream=$omg_merge_tracking_branch_symbol
					fi

					if [ "$has_diverged" = true ]; then
						prompt+=$(enrich_append true "-${commits_behind}${omg_has_diverged_symbol}+${commits_ahead}" "${vcs_color}")
					else
						if [ "$commits_behind" -gt 0 ]; then
							prompt+=$(enrich_append true "-${commits_behind}${omg_can_fast_forward_symbol}" "${vcs_color}")
						fi
						if [ "$commits_ahead" -gt 0 ]; then
							prompt+=$(enrich_append true "${omg_should_push_symbol} +${commits_ahead}" "${vcs_color}")
						fi
						
					fi
					local upstream_str=${upstream/\/$current_branch/}
					upstream_str=${upstream_str/$current_branch/[…]}
					prompt+=$(enrich_append true "(${current_branch} ${type_of_upstream} ${upstream_str})" "${vcs_color}")
				fi
			fi
			prompt+=$(enrich_append ${is_on_a_tag} "${omg_is_on_a_tag_symbol}${tag_at_current_commit}" "${vcs_color}")

			top_level=$(git rev-parse --show-toplevel)
			color=${path_color}
			arrow="${vcs_to_path_color}${omg_arrow}"
			prompt+="${vcs_to_path_color}${omg_arrow} ${path_color_highlight}$(basename ${top_level})"
			path=$(pwd|sed s,${top_level},,)
			arrow="${path_separator_color} ${omg_separator}";
		else
			prompt+="${user_color} \u "
			arrow="${user_to_path_color}${omg_arrow}";
		fi
		for rep in $(echo ${path}|sed "s,${HOME},~,"|tr / ' '); do
			[ $rep = ${last_rep} ] && color="${path_color_last}" || color=${path_color}
			prompt+="${arrow}${color} ${rep}"
			arrow="${path_separator_color} ${omg_separator}";
		done
		prompt+=" ${omg_reset}${path_end_color}${omg_arrow} ${omg_reset}"
		prompt+="$(eval_prompt_callback_if_present)"

		echo -e "${prompt}\e[K"
	}

	PS2="\[${omg_fg_darkgray}\]${omg_arrow}${omg_reset} "

	function bash_prompt() {
		PS1="$(build_prompt)"
	}

	PROMPT_COMMAND=bash_prompt

fi
