PSORG=$PS1;

: ${omg_theme=green}
: ${omg_theme_variant=} #dark


if [ -n "${BASH_VERSION}" ]; then
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	source ${DIR}/base.sh

	: ${omg_ungit_prompt:=$PS1}

	: ${omg_is_a_git_repo_symbol:=''}
	: ${omg_has_untracked_files_symbol:=''}        #                ?    
	: ${omg_has_adds_symbol:=''}
	: ${omg_has_deletions_symbol:=''}
	: ${omg_has_cached_deletions_symbol:=''}
	: ${omg_has_modifications_symbol:=''}
	: ${omg_has_cached_modifications_symbol:=''}
	: ${omg_ready_to_commit_symbol:=''}            #   →
	: ${omg_is_on_a_tag_symbol:=''}                #   
	: ${omg_needs_to_merge_symbol:='ᄉ'}
	: ${omg_detached_symbol:=''}
	: ${omg_can_fast_forward_symbol:=''}
	: ${omg_has_diverged_symbol:=''}               #   
	: ${omg_not_tracked_branch_symbol:=''}
	: ${omg_rebase_tracking_branch_symbol:=''}     #   
	: ${omg_merge_tracking_branch_symbol:=''}      #  
	: ${omg_should_push_symbol:=''}                #    
	: ${omg_has_stashes_symbol:=''}

	: ${omg_default_color_on:='\[\033[1;37m\]'}
	: ${omg_default_color_off:='\[\033[0m\]'}
	: ${omg_last_symbol_color:='\e[0;32m'} #'\e[0;32m\e[40m'}
	
	PROMPT='$(build_prompt)'
	RPROMPT='%{$reset_color%}%T %{$fg_bold[white]%} %n@%m%{$reset_color%}'

	function enrich_append {
		local flag=$1
		local symbol=$2
		local color=${3:-$omg_default_color_on}
		if [[ $flag == false ]]; then symbol=''; fi
		[ -z "$symbol" ] || symbol+=' '

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

		local bold='\e[1m'
		local normal='\e[0m'

		local blue='31'
		local dark_blue='24'
		local green='29'
		local dark_green='23'
		local gray='250'
		local medium_gray='245'
		local dark_gray='240'
		local white='231'

		# foreground
		local fg_blue="\e[38;5;${blue}m"
		local fg_darkblue="\e[38;5;${dark_blue}m"
		local fg_green="\e[38;5;${green}m"
		local fg_darkgreen="\e[38;5;${dark_green}m"
		local fg_gray="\e[38;5;${gray}m"
		local fg_mediumgray="\e[38;5;${medium_gray}m"
		local fg_darkgray="\e[38;5;${dark_gray}m"
		local fg_white="\e[38;5;${white}m"

		#background
		local bg_blue="\e[48;5;${blue}m"
		local bg_darkblue="\e[48;5;${dark_blue}m"
		local bg_green="\e[48;5;${green}m"
		local bg_darkgreen="\e[48;5;${dark_green}m"
		local bg_gray="\e[48;5;${gray}m"
		local bg_mediumgray="\e[48;5;${medium_gray}m"
		local bg_darkgray="\e[48;5;${dark_gray}m"
		local bg_white="\e[48;5;${white}m"

		local fg_theme=fg_${omg_theme_variant}${omg_theme}
		local bg_theme=bg_${omg_theme_variant}${omg_theme}

		local reset='\[\e[0m\]'     # Text Reset]'

		local user_color="\[${bold}${fg_white}${!bg_theme}\]"
		local user_to_path_color="\[${bold}${!fg_theme}${bg_darkgray}\]"
		local path_color="\[${normal}${fg_gray}${bg_darkgray}\]"
		local path_separator_color="\[${normal}${fg_mediumgray}${bg_darkgray}\]"
		local path_color_last="\[${bold}${fg_gray}${bg_darkgray}\]"
		local path_color_highlight="\[${bold}${fg_white}${bg_darkgray}\]"
		local path_end_color="\[${bold}${fg_darkgray}\]"
		local vcs_info_color="\[${normal}${fg_white}${!bg_theme}\]"
		local vcs_info_color_arrow="\[${normal}${fg_white}${!bg_theme}\]"
		local vcs_to_path_color="\[${bold}${!fg_theme}${bg_darkgray}\]"

		# Flags
		local omg_default_color_on="${black_on_white}"

		local top_level
		local color
		local arrow
		local path=$(pwd)
		local last_rep=$(basename ${path})


		if [[ $is_a_git_repo == true ]]; then
			# on filesystem
			prompt="${vcs_info_color} "
			prompt+=$(enrich_append $is_a_git_repo $omg_is_a_git_repo_symbol "${vcs_info_color}")
			prompt+=$(enrich_append $has_stashes $omg_has_stashes_symbol "${vcs_info_color}")

			prompt+=$(enrich_append $has_untracked_files $omg_has_untracked_files_symbol "${vcs_info_color}")
			prompt+=$(enrich_append $has_modifications $omg_has_modifications_symbol "${vcs_info_color}")
			prompt+=$(enrich_append $has_deletions $omg_has_deletions_symbol "${vcs_info_color}")
			

			# ready
			prompt+=$(enrich_append $has_adds $omg_has_adds_symbol "${vcs_info_color}")
			prompt+=$(enrich_append $has_modifications_cached $omg_has_cached_modifications_symbol "${vcs_info_color}")
			prompt+=$(enrich_append $has_deletions_cached $omg_has_cached_deletions_symbol "${vcs_info_color}")
			# next operation

			prompt+=$(enrich_append $ready_to_commit $omg_ready_to_commit_symbol "${vcs_info_color}")

			# where

			prompt+=" ${vcs_info_color}"
			if [[ $detached == true ]]; then
				prompt+=$(enrich_append $detached $omg_detached_symbol "${vcs_info_color}")
				prompt+=$(enrich_append $detached "(${current_commit_hash:0:7})" "${vcs_info_color}")
			else            
				if [[ $has_upstream == false ]]; then
					prompt+=$(enrich_append true "${omg_not_tracked_branch_symbol} (${current_branch})" "${vcs_info_color}")
				else
					if [[ $will_rebase == true ]]; then
						local type_of_upstream=$omg_rebase_tracking_branch_symbol
					else
						local type_of_upstream=$omg_merge_tracking_branch_symbol
					fi

					if [[ $has_diverged == true ]]; then
						prompt+=$(enrich_append true "-${commits_behind}${omg_has_diverged_symbol}+${commits_ahead}" "${vcs_info_color}")
					else
						if [[ $commits_behind -gt 0 ]]; then
							prompt+=$(enrich_append true "-${commits_behind}${white_on_green}${omg_can_fast_forward_symbol}${vcs_info_color}" "${vcs_info_color}")
						fi
						if [[ $commits_ahead -gt 0 ]]; then
							prompt+=$(enrich_append true "${white_on_green}${omg_should_push_symbol}${vcs_info_color} +${commits_ahead}" "${vcs_info_color}")
						fi
						
					fi
					prompt+=$(enrich_append true "(${current_branch} ${type_of_upstream} ${upstream//\/$current_branch/})" "${vcs_info_color}")
				fi
			fi
			prompt+=$(enrich_append ${is_on_a_tag} "${omg_is_on_a_tag_symbol}${tag_at_current_commit}" "${vcs_info_color}")

			top_level=$(git rev-parse --show-toplevel)
			color=${path_color}
			arrow="${vcs_to_path_color}"
			prompt+="${vcs_to_path_color} ${path_color_highlight}$(basename ${top_level})"
			path=$(pwd|sed s,${top_level},,)
			arrow="${path_separator_color} ";
		else
			prompt+="${user_color} \u "
			arrow="${user_to_path_color}";
		fi
		for rep in $(echo ${path}|sed "s,${HOME},~,"|tr / ' '); do
			[ $rep = ${last_rep} ] && color="${path_color_last}" || color=${path_color}
			prompt+="${arrow}${color} ${rep}"
			arrow="${path_separator_color} ";
		done
		[ "${color}" = "${black_on_white}" ] && arrow_color=${white} || arrow_color=${green}
		prompt+=" ${reset}${path_end_color} ${reset}"
		prompt+="$(eval_prompt_callback_if_present)"

		echo -e "${prompt}"
	}

	PS2="\[\e[1m\e[38;5;240m\]\[\e[0m\] "

	function bash_prompt() {
		PS1="$(build_prompt)"
	}

	PROMPT_COMMAND=bash_prompt

fi
