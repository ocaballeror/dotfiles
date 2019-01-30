if exists('b:current_syntax')
	unlet b:current_syntax
endif

if !exists('no_cmusrc_shell')
	syn include @shellCommand syntax/sh.vim
	syn region shellRegion
				\ matchgroup=EmbeddedSH
				\ start=" "
				\ end="\n"
				\ contains=@shellCommand

	syn keyword cmusrcKeyword 		contained shell
									\ nextgroup=@shellRegion
else
	syn keyword cmusrcKeyword 		contained shell
endif



syn keyword cmusrcOption        contained auto_expand_albums_follow
								\ auto_expand_albums_search
								\ auto_expand_albums_selcur
								\ display_artist_sort_name
								\ follow smart_artist_sort
								\ repeat_current replaygain_limit
								\ resume show_all_tracks
								\ set_term_title show_current_bitrate
								\ show_playback_position skip_track_info
								\ wrap_search mouse softvol
								\ nextgroup=cmusrcSetTest,cmusrcOptEqBoolean


syn keyword cmusrcTogglableOpt 	contained auto_expand_albums_follow
								\ auto_expand_albums_search
								\ auto_expand_albums_selcur
								\ display_artist_sort_name
								\ follow smart_artist_sort
								\ repeat_current replaygain
								\ replaygain_limit set_term_title
								\ resume show_all_tracks
								\ set_term_title show_current_bitrate
								\ show_playback_position skip_track_info
								\ wrap_search mouse softvol
								\ nextgroup=cmusrcOptEqBoolean

syn keyword cmusrcOption        contained format_current format_trackwin_album format_treewin
								\ format_playlist_va format_statusline
								\ format_trackwin_va format_treewin_artist
								\ nextgroup=cmusrcOptEqFormat

syn keyword cmusrcOption 		contained icecast_default_charset
								\ nextgroup=cmusrcOptEqString

syn keyword cmusrcOption 		contained rewind_offset scroll_offset
								\ nextgroup=cmusrcOptEqNumber

syn keyword cmusrcOption 		contained softvol_state
								\ nextgroup=cmusrcOptEqDoubleNumber

syn match cmusrcOptEqDoubleNumber contained '='
								\ nextgroup=cmusrcDoubleNumber

syn match cmusrcDoubleNumber 	contained '\d\+\s\+\d\+'

syn keyword cmusrcOption 		contained replaygain_preamp
								\ nextgroup=cmusrcOptEqFloat

syn match cmusrcOptEqFloat 		contained '='
								\ nextgroup=cmusrcOptFloat

syn match cmusrcOptFloat 		contained '\d\+\.\d\+'

syn keyword cmusrcOption 		contained replaygain
								\ nextgroup=cmusrcEqReplayGain

syn match cmusrcEqReplayGain 	contained '='
								\ nextgroup=cmusrcOptReplayGain

syn keyword cmusrcOptReplayGain contained track disabled album
								\ track-preferred album-preferred


syn keyword cmusrcOption        contained  color_cmdline_attr color_cur_sel_attr
								\ color_statusline_attr color_titleline_attr
								\ color_win_attr color_win_cur_sel_attr
								\ color_win_inactive_cur_sel_attr color_win_inactive_sel_attr
								\ color_win_sel_attr color_win_title_attr
								\ nextgroup=cmusrcOptEqAttr

syn match cmusrcOptEqAttr 		contained '='
								\ nextgroup=cmusrcOptAttr

syn keyword cmusrcOptAttr 		contained default standout bold
								\ reverse underline blink

syn keyword cmusrcOption 		contained device
								\ nextgroup=cmusrcOptEqFile
" syn match cmusrcFile 			contained display '/.[^/]*/|$'
syn match cmusrcOptEqFile 		contained display '='
								\ nextgroup=cmusrcFile

syn keyword cmusrcKeyword 		contained prev-view pwd win-page-bottom
								\ win-page-middle win-page-top
								\ win-scroll-down win-scroll-up

syn keyword cmusrcKeyword 		contained live-filter
								\ nextgroup=cmusrcFilterExpr

syn keyword cmusrcKeyword 		contained lqueue tqueue

syn keyword cmusrcKeyword 		contained push
								\ nextgroup=cmusrcOptString

syn keyword cmusrcKeyword 		contained update-cache win-update-cache
								\ nextgroup=cmusrcCacheSwitches

syn match cmusrcCacheSwitches 	contained display '-[f]'


hi def link cmusrcDoubleNumber 	Number
hi def link cmusrcOptFloat 		Number
hi def link cmusrcOptReplayGain Identifier
hi def link cmusrcOptAttr 		Identifier
hi def link cmusrcCacheSwtiches cmusrcSwitches
