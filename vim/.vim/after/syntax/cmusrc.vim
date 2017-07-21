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



syn keyword cmusrcOption        contained follow show_current_bitrate
								\ nextgroup=cmusrcSetTest,cmusrcOptEqBoolean 

syn keyword cmusrcOption        contained format_current format_trackwin_album format_treewin
								\ nextgroup=cmusrcOptEqFormat


syn keyword cmusrcOption        contained  color_cmdline_attr color_cur_sel_attr
								\ color_statusline_attr color_titleline_attr
								\ color_win_attr color_win_cur_sel_attr
								\ color_win_inactive_cur_sel_attr color_win_inactive_sel_attr
								\ color_win_sel_attr color_win_title_attr                             
								\ nextgroup=cmusrcOptEqColor
