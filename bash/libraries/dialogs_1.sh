#!/bin/bash

# Copyright 2021 F8ER

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Meta
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# A prefix of the library internal members: "Lib_Dialog_1_0_"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Internal functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lib_Dialog_1_0_RT
{
	declare line_l;

	for line_l in "${@:2}";
	do 
		if ! [[ "$line_l" =~ $1 ]];
		then
			return 1;
		fi
	done

	return 0;
}

function Lib_Dialog_1_0_OR
{
	declare index_l;
	
	for (( index_l = 1; index_l <= "$1"; index_l++ ));
	do
		printf "%s" "$2";
	done
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Internal variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Lib_Dialog_1_0_TERM="$TERM";
Lib_Dialog_1_0_TERMCustom='xterm-256color';
Lib_Dialog_1_0_dialogRcData=$( \
	printf '%s\n' \
		'use_shadow = OFF' \
		'use_colors = ON' \
		'title_color = (BLACK,BLACK,ON)' \
		'screen_color = (BLACK,BLACK,OFF)' \
		'dialog_color = (WHITE,BLACK,ON)' \
		'border_color = title_color' \
		'border2_color = title_color' \
		'inputbox_color = title_color' \
		'inputbox_border_color = title_color' \
		'inputbox_border2_color = title_color' \
		'menubox_color = title_color' \
		'menubox_border_color = title_color' \
		'menubox_border2_color = title_color' \
		'searchbox_color = title_color' \
		'searchbox_title_color = title_color' \
		'searchbox_border_color = border_color' \
		'searchbox_border2_color = title_color' \
		'form_active_text_color = dialog_color' \
		'form_text_color = form_active_text_color' \
		'form_item_readonly_color = title_color' \
		'button_active_color = form_active_text_color' \
		'button_inactive_color = title_color' \
		'button_key_active_color = button_active_color' \
		'button_key_inactive_color = dialog_color' \
		'button_label_active_color = (BLACK,WHITE,OFF)' \
		'button_label_inactive_color = dialog_color' \
		'position_indicator_color = title_color' \
		'item_color = title_color' \
		'item_selected_color = button_active_color' \
		'tag_color = title_color' \
		'tag_selected_color = button_active_color' \
		'tag_key_color = title_color' \
		'tag_key_selected_color = button_active_color' \
		'check_color = title_color' \
		'check_selected_color = button_active_color' \
		'uarrow_color = title_color' \
		'darrow_color = uarrow_color' \
		'itemhelp_color = title_color' \
		'gauge_color = title_color'; \
);

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Library functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function DialogSimple
{
	declare message_l='';
	declare title_l='';
	declare backTitle_l='';
	declare formWidth_l=12;
	declare okLabel_l=" OK ";
	declare centered_l=0;
	declare Lib_Dialog_1_0_dialogRcData_l="$Lib_Dialog_1_0_dialogRcData";
	declare OPTIND;
	declare OPTARG;
	declare o_l;

	while getopts ":m:t:b:w:y:c" o_l; do
		case "$o_l" in
			"m")
				message_l="$OPTARG";
			;;
			"t")
				title_l="$OPTARG";
			;;
			"b")
				backTitle_l="$OPTARG";
			;;
			"w")
				if (( formWidth_l < "$OPTARG" ));
				then
					formWidth_l="$OPTARG";
				fi
			;;
			"y")
				okLabel_l=" $OPTARG ";
			;;
			"c")
				centered_l=1;
			;;
		esac
	done
	
	shift $(( OPTIND - 1 ));

	if (( ${#backTitle_l} > 0 ));
	then
		Lib_Dialog_1_0_dialogRcData_l="${Lib_Dialog_1_0_dialogRcData/screen_color = (BLACK,BLACK,OFF)/screen_color = (BLACK,BLACK,ON)}";
	fi

	declare messageLine_l;
	declare messageLengthMax_l=0;

	for messageLine_l in "$( printf "$message_l\n" )"; do
		if (( $messageLengthMax_l < ${#messageLine_l} ));
		then
			messageLengthMax_l=${#messageLine_l};
		fi
	done

	if (( ${#okLabel_l} > 6 )) && (( formWidth_l < 12 + ( ${#okLabel_l} - 6 ) * 2 + 2 ));
	then
		formWidth_l=$(( 12 + ( ${#okLabel_l} - 6 ) ));
	fi

	if (( formWidth_l < messageLengthMax_l + 4 ));
	then
		formWidth_l=$(( messageLengthMax_l + 4 ));
	fi

	declare messageLines_l="$( printf "$message_l\n" | grep -c '^' )";
	declare messagePrepared_l;

	if [ "$centered_l" = "1" ];
	then
		for messageLine_l in "$( printf "$message_l\n" )"; do
			declare messagePadding_l=$(( (formWidth_l - ${#messageLine_l}) / 2 - 3 ));

			if (( $messagePadding_l < 0 ));
			then
				messagePadding_l=0;
			fi

			messagePrepared_l="$( printf '%s%s' "$messagePrepared_l" "$( Lib_Dialog_1_0_OR "$messagePadding_l" ' ' )${messageLine_l}\n" )";
		done
	else
		messagePrepared_l="$message_l";
	fi

	TERM="$Lib_Dialog_1_0_TERMCustom";
	declare result_l;
	result_l="$( \
		DIALOGRC=<( \
			printf '%s\n' "$Lib_Dialog_1_0_dialogRcData_l" \
		) \
			dialog \
				--backtitle "\Z7$backTitle_l" \
				--title "$title_l" \
				--colors \
				--ok-label "$okLabel_l" \
				--msgbox \
					"$messagePrepared_l" \
					"$((4 + messageLines_l))" "$formWidth_l" \
			3>&1 1>&2 2>&3 3>&-;
	)";
	TERM="$Lib_Dialog_1_0_TERM";

	return $?;
}

function DialogYesNo
{
	declare message_l='';
	declare title_l='';
	declare backTitle_l='';
	declare formWidth_l=19;
	declare yesLabel_l=" Yes ";
	declare noLabel_l=" No ";
	declare centered_l=0;
	declare Lib_Dialog_1_0_dialogRcData_l="$Lib_Dialog_1_0_dialogRcData";
	declare OPTIND;
	declare OPTARG;
	declare o_l;

	while getopts ":m:t:b:w:y:n:c" o_l; do
		case "$o_l" in
			"m")
				message_l="$OPTARG";
			;;
			"t")
				title_l="$OPTARG";
			;;
			"b")
				backTitle_l="$OPTARG";
			;;
			"w")
				if (( formWidth_l < "$OPTARG" ));
				then
					formWidth_l="$OPTARG";
				fi
			;;
			"y")
				yesLabel_l=" $OPTARG ";
			;;
			"n")
				noLabel_l=" $OPTARG ";
			;;
			"c")
				centered_l=1;
			;;
		esac
	done

	shift $(( OPTIND - 1 ));

	if (( ${#backTitle_l} > 0 ));
	then
		Lib_Dialog_1_0_dialogRcData_l="${Lib_Dialog_1_0_dialogRcData/screen_color = (BLACK,BLACK,OFF)/screen_color = (BLACK,BLACK,ON)}";
	fi

	declare messageLine_l;
	declare messageLengthMax_l=0;

	for messageLine_l in "$( printf "$message_l\n" )"; do
		if (( $messageLengthMax_l < ${#messageLine_l} ));
		then
			messageLengthMax_l=${#messageLine_l};
		fi
	done

	if (( ${#yesLabel_l} > 6 )) || (( ${#noLabel_l} > 6 ));
	then
		if (( ${#yesLabel_l} > ${#noLabel_l} ));
		then
			if (( formWidth_l < 19 + ( ${#yesLabel_l} - 6 ) * 2 + 2 ));
			then
				formWidth_l=$(( 19 + ( ${#yesLabel_l} - 6 ) * 2 + 2 ));
			fi
		else
			if (( formWidth_l < 19 + ( ${#noLabel_l} - 6 ) * 2 + 2 ));
			then
				formWidth_l=$(( 19 + ( ${#noLabel_l} - 6 ) * 2 + 2 ));
			fi
		fi
	fi

	if (( formWidth_l < messageLengthMax_l + 4 ));
	then
		formWidth_l=$(( messageLengthMax_l + 4 ));
	fi

	declare messageLines_l="$( printf "$message_l\n" | grep -c '^' )";
	declare messagePrepared_l;

	if [ "$centered_l" = "1" ];
	then
		for messageLine_l in "$( printf "$message_l\n" )"; do
			declare messagePadding_l=$(( (formWidth_l - ${#messageLine_l}) / 2 - 3 ));

			if (( $messagePadding_l < 0 ));
			then
				messagePadding_l=0;
			fi

			messagePrepared_l="$( printf '%s%s' "$messagePrepared_l" "$( Lib_Dialog_1_0_OR "$messagePadding_l" ' ' )${messageLine_l}\n" )";
		done
	else
		messagePrepared_l="$message_l";
	fi

	TERM="$Lib_Dialog_1_0_TERMCustom";
	declare result_l;
	result_l="$( \
		DIALOGRC=<( \
			printf '%s\n' "$Lib_Dialog_1_0_dialogRcData_l" \
		) \
			dialog \
				--backtitle "\Z7$backTitle_l" \
				--title "$title_l" \
				--colors \
				--yes-label "$yesLabel_l" \
				--no-label "$noLabel_l" \
				--yesno \
					"$messagePrepared_l" \
					"$((4 + messageLines_l))" "$formWidth_l" \
			3>&1 1>&2 2>&3 3>&-;
	)";
	TERM="$Lib_Dialog_1_0_TERM";

	return $?;
}

function DialogPrompt
{
	declare message_l='';
	declare title_l='';
	declare backTitle_l='';
	declare formWidth_l=19;
	declare okLabel_l=" Yes ";
	declare cancelLabel_l=" No ";
	declare centered_l=0;
	declare Lib_Dialog_1_0_dialogRcData_l="$Lib_Dialog_1_0_dialogRcData";
	declare OPTIND;
	declare OPTARG;
	declare o_l;

	while getopts ":m:t:b:w:y:n:c" o_l; do
		case "$o_l" in
			"m")
				message_l="$OPTARG";
			;;
			"t")
				title_l="$OPTARG";
			;;
			"b")
				backTitle_l="$OPTARG";
			;;
			"w")
				if (( formWidth_l < "$OPTARG" ));
				then
					formWidth_l="$OPTARG";
				fi
			;;
			"y")
				okLabel_l=" $OPTARG ";
			;;
			"n")
				cancelLabel_l=" $OPTARG ";
			;;
			"c")
				centered_l=1;
			;;
		esac
	done

	shift $(( OPTIND - 1 ));

	if (( ${#backTitle_l} > 0 ));
	then
		Lib_Dialog_1_0_dialogRcData_l="${Lib_Dialog_1_0_dialogRcData/screen_color = (BLACK,BLACK,OFF)/screen_color = (BLACK,BLACK,ON)}";
	fi

	declare inputArray_l=( "$@" );
	declare inputsTitleMax_l=0;

	while (( ${#inputArray_l[@]} > 0 )); do
		declare inputTitle_l="${inputArray_l[@]:2:1}";

		if (( ${#inputTitle_l} > inputsTitleMax_l )); then
			inputsTitleMax_l=${#inputTitle_l};
		fi

		inputArray_l=("${inputArray_l[@]:5}");
	done

	if (( ${#okLabel_l} > 6 )) || (( ${#cancelLabel_l} > 6 ));
	then
		if (( ${#okLabel_l} > ${#cancelLabel_l} ));
		then
			if (( formWidth_l < 19 + ( ${#okLabel_l} - 6 ) * 2 + 2 ));
			then
				formWidth_l=$(( 19 + ( ${#okLabel_l} - 6 ) * 2 + 2 ));
			fi
		else
			if (( formWidth_l < 19 + ( ${#cancelLabel_l} - 6 ) * 2 + 2 ));
			then
				formWidth_l=$(( 19 + ( ${#cancelLabel_l} - 6 ) * 2 + 2 ));
			fi
		fi
	fi

	# 11 ~= form borders width(6) + margin(4) + gap between input title and field(1)
	if (( formWidth_l < inputsTitleMax_l * 2 + 11 ));
	then
		formWidth_l=$(( inputsTitleMax_l * 2 + 11 ));
	elif [ "$centered_l" = "1" ];
	then
		inputsTitleMax_l=$(( formWidth_l / 2 - 11 / 2 ));
	fi

	# declare inputArray_l=( "${@:8}" );
	declare inputArray_l=( "$@" );
	declare inputVars_l=();
	declare inputRegexes_l=();
	declare inputArguments_l=();

	# From `man dialog`:
	# label y x item y x flen ilen
	# The field length flen and input-length ilen tell how long the field can be.
	# If flen is zero, the corresponding field cannot be altered. and the contents of the field determine the displayed-length.
	# If flen is negative, the corresponding field cannot be altered, and the negated value of flen is used as the displayed-length.
	# If ilen is zero, it is set to flen.
	while (( ${#inputArray_l[@]} > 0 ));
	do
		inputVars_l+=( "${inputArray_l[@]:0:1}" );
		inputRegexes_l+=( "${inputArray_l[@]:4:1}" );
		inputArguments_l+=( \
			"$( printf "%${inputsTitleMax_l}s" "${inputArray_l[@]:2:1}" ) |" \
			"${#inputVars_l[@]}" 2 \
			"${inputArray_l[@]:3:1}" \
			"${#inputVars_l[@]}" "$((inputsTitleMax_l + 5))" \
			"$(( ${inputArray_l[@]:1:1} > 0 ? inputsTitleMax_l : 0 ))" "${inputArray_l[@]:1:1}" \
		);
		inputArray_l=( "${inputArray_l[@]:5}" );
	done

	declare result_l;

	while true;
	do
		TERM="$Lib_Dialog_1_0_TERMCustom";
		result_l="$( \
			DIALOGRC=<( \
				printf '%s\n' "$Lib_Dialog_1_0_dialogRcData_l" \
			) \
				dialog \
					--backtitle "\Z7$backTitle_l" \
					--title "$title_l" \
					--colors \
					--ok-label "$okLabel_l" \
					--cancel-label "$cancelLabel_l" \
					--form \
						"$message_l" \
						"$((6 + ${#inputVars_l[@]} + $( printf "$message_l" | grep -c '^' )))" "$formWidth_l" 0 \
						"${inputArguments_l[@]}" \
				3>&1 1>&2 2>&3 3>&-; \
		)";
		TERM="$Lib_Dialog_1_0_TERM";

		if [ $? != 0 ];
		then
			return 1;
		fi

		declare correct_l=1;

		for (( inputVars_l_i = 0; inputVars_l_i < ${#inputVars_l[@]}; inputVars_l_i++ )); do
			declare regex_l="${inputRegexes_l[$inputVars_l_i]}";

			if [ "$regex_l" != "" ];
			then
				declare value_l="$( echo "$result_l" | sed "$(($inputVars_l_i + 1))q;d" )";

				if ! Lib_Dialog_1_0_RT "$regex_l" "$value_l";
				then
					correct_l=0;

					break;
				fi
			fi
		done

		if [ "$correct_l" != 1 ];
		then
			continue;
		fi

		for (( inputVars_l_i = 0; inputVars_l_i < ${#inputVars_l[@]}; inputVars_l_i++ ));
		do
			declare -g "${inputVars_l[$inputVars_l_i]}"="$( echo "$result_l" | sed "$(($inputVars_l_i + 1))q;d" )";
		done

		break;
	done
}

function DialogList
{
	declare message_l='';
	declare title_l='';
	declare backTitle_l='';
	declare formWidth_l=19;
	declare okLabel_l=" Yes ";
	declare cancelLabel_l=" No ";
	declare Lib_Dialog_1_0_dialogRcData_l="$Lib_Dialog_1_0_dialogRcData";
	declare OPTIND;
	declare OPTARG;
	declare o_l;

	while getopts ":m:t:b:w:y:n:" o_l; do
		case "$o_l" in
			"m")
				message_l="$OPTARG";
			;;
			"t")
				title_l="$OPTARG";
			;;
			"b")
				backTitle_l="$OPTARG";
			;;
			"w")
				if (( formWidth_l < "$OPTARG" ));
				then
					formWidth_l="$OPTARG";
				fi
			;;
			"y")
				okLabel_l=" $OPTARG ";
			;;
			"n")
				cancelLabel_l=" $OPTARG ";
			;;
		esac
	done

	shift $(( OPTIND - 1 ));

	if (( ${#backTitle_l} > 0 ));
	then
		Lib_Dialog_1_0_dialogRcData_l="${Lib_Dialog_1_0_dialogRcData/screen_color = (BLACK,BLACK,OFF)/screen_color = (BLACK,BLACK,ON)}";
	fi

	declare listsTitleMax_l=0;
	declare listIndex_l;
	declare listArguments_l=();

	for (( listIndex_l = 1; listIndex_l < $# + 1; listIndex_l++ )); do
		declare listTitle_l="${@:$listIndex_l:1}";

		if (( ${#listTitle_l} > listsTitleMax_l )); then
			listsTitleMax_l=${#listTitle_l};
		fi

		listArguments_l+=( $listIndex_l "${@:$listIndex_l:1}" );
	done

	if (( ${#okLabel_l} > 5 )) || (( ${#cancelLabel_l} > 6 ));
	then
		if (( ${#okLabel_l} > ${#cancelLabel_l} ));
		then
			if (( formWidth_l < 19 + ( ${#okLabel_l} - 6 ) * 2 + 2 ));
			then
				formWidth_l=$(( 19 + ( ${#okLabel_l} - 6 ) * 2 + 2 ));
			fi
		else
			if (( formWidth_l < 19 + ( ${#cancelLabel_l} - 6 ) * 2 + 2 ));
			then
				formWidth_l=$(( 19 + ( ${#cancelLabel_l} - 6 ) * 2 + 2 ));
			fi
		fi
	fi

	# 11 ~= form borders width(6) + margin(4) + gap(1)
	if (( formWidth_l < listsTitleMax_l + 11 ));
	then
		formWidth_l=$(( listsTitleMax_l + 11 ));

		declare listTagMax_l=$(( $# + 1 ));

		if (( ${#listTagMax_l} > 1 ));
		then
			formWidth_l=$(( formWidth_l + ( ${#listTagMax_l} - 1 ) ));
		fi
	fi

	TERM="$Lib_Dialog_1_0_TERMCustom";
	declare result_l;
	result_l="$( \
		DIALOGRC=<( \
			printf '%s\n' "$Lib_Dialog_1_0_dialogRcData_l" \
		) \
			dialog \
				--backtitle "\Z7$backTitle_l" \
				--title "$title_l" \
				--colors \
				--ok-label "$okLabel_l" \
				--cancel-label "$cancelLabel_l" \
				--menu \
					"$message_l" \
					"$((6 + ${#listVars_l[@]} + $( printf "$message_l" | grep -c '^' )))" "$formWidth_l" 0 \
					"${listArguments_l[@]}" \
			3>&1 1>&2 2>&3 3>&-; \
	)";
	TERM="$Lib_Dialog_1_0_TERM";

	if [ $? != 0 ];
	then
		return 1;
	fi

	echo "$result_l";
}

function DialogFile
{
	declare filepath_l='./';
	declare filename_l="file_$( printf '%(%H%M%S_%d%m%Y)T' ).txt";
	declare title_l='';
	declare backTitle_l='';
	declare formWidth_l=100;
	declare formHeight_l=20;
	declare okLabel_l=" Yes ";
	declare cancelLabel_l=" No ";
	declare Lib_Dialog_1_0_dialogRcData_l="$Lib_Dialog_1_0_dialogRcData";
	declare OPTIND;
	declare OPTARG;
	declare o_l;

	while getopts ":p:f:t:b:w:h:y:n:" o_l; do
		case "$o_l" in
			"p")
				filepath_l="$OPTARG";
			;;
			"f")
				filename_l="$OPTARG";
			;;
			"t")
				title_l="$OPTARG";
			;;
			"b")
				backTitle_l="$OPTARG";
			;;
			"w")
				if (( 0 <= "$OPTARG" ));
				then
					formWidth_l="$OPTARG";
				fi
			;;
			"h")
				if (( 0 <= "$OPTARG" ));
				then
					formHeight_l="$OPTARG";
				fi
			;;
			"y")
				okLabel_l=" $OPTARG ";
			;;
			"n")
				cancelLabel_l=" $OPTARG ";
			;;
		esac
	done

	shift $(( OPTIND - 1 ));

	if (( ${#backTitle_l} > 0 ));
	then
		Lib_Dialog_1_0_dialogRcData_l="${Lib_Dialog_1_0_dialogRcData/screen_color = (BLACK,BLACK,OFF)/screen_color = (BLACK,BLACK,ON)}";
	fi

	backTitle_l="${formWidth_l}x${formHeight_l}";

	if (( ${#okLabel_l} > 5 )) || (( ${#cancelLabel_l} > 6 ));
	then
		if (( ${#okLabel_l} > ${#cancelLabel_l} ));
		then
			if (( formWidth_l < 19 + ( ${#okLabel_l} - 6 ) * 2 + 2 ));
			then
				formWidth_l=$(( 19 + ( ${#okLabel_l} - 6 ) * 2 + 2 ));
			fi
		else
			if (( formWidth_l < 19 + ( ${#cancelLabel_l} - 6 ) * 2 + 2 ));
			then
				formWidth_l=$(( 19 + ( ${#cancelLabel_l} - 6 ) * 2 + 2 ));
			fi
		fi
	fi

	TERM="$Lib_Dialog_1_0_TERMCustom";
	declare result_l;
	result_l="$( \
		DIALOGRC=<( \
			printf '%s\n' "$Lib_Dialog_1_0_dialogRcData_l" \
		) \
			dialog \
				--backtitle "\Z7$backTitle_l" \
				--title "$title_l" \
				--colors \
				--ok-label "$okLabel_l" \
				--cancel-label "$cancelLabel_l" \
				--fselect \
					"${filepath_l}${filename_l}" $formHeight_l $formWidth_l \
			3>&1 1>&2 2>&3 3>&-; \
	)";
	TERM="$Lib_Dialog_1_0_TERM";

	if [ $? != 0 ];
	then
		return 1;
	fi

	echo "$result_l";
}
