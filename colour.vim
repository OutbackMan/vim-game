" save and restore matches before loading

" Cyan_Red_bold/NONE"
function! SET_CH(x, y, ch, bg_fg_weight_group)
  let match_pattern = '' . x . '_' . y

  if has_key(g:match_patterns, match_pattern)
    if g:match_patterns[match_pattern]['bg_fg_group'] == a:bg_fg_group
		return
	else
		call matchdelete(g:match_patterns[match_pattern]['match_id'])
	endif
  endif

  if index(g:bg_fg_groups, a:bg_fg_group) < 0
    let [bg_color, fg_color, weight] = split(a:bg_fg_group, '_')
    execute 'highlight ' . a:bg_fg_group . ' ctermbg=' . bg_color .' guibg=' . bg_color . 
	  \' ctermfg=' . fg_color . ' guifg='. fg_color . ' cterm=' . weight .
	  \' gui=' . weight
	add(g:bg_fg_groups, a:bg_fg_group)
  endif

  let match_id = matchaddpos(a:bg_fg_group, [x, y])
  g:match_patterns[match_pattern] = {
	'match_id': match_id,
	'bg_fg_weight_group': a:bg_fg_group
  }
endfunction
