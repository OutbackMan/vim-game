" save and restore matches before loading

function! TE_CreateTab(name, desired_tab_width, desired_tab_height)
  if &columns < a:desired_tab_width
    echomsg '[TE - Error] Current maximum tab width of ' . &columns . 
	  \' is less than desired tab width of ' . a:desired_tab_width

	return v:none
  elseif &lines < a:desired_tab_height
    echomsg '[TE - Error] Current maximum tab height of ' . &lines . 
	  \' is less than desired tab height of ' . a:desired_tab_height

	return v:none
  else
    tabnew a:name

    return {
	  'width': a:desired_tab_width,
	  'height': a:desired_tab_height
    }
  endif
endfunction

" Cyan_Red_bold/NONE"
function! TE_CreateRenderer(te_tab, default_ch, default_bg_fg_weight_group)
  let renderer = { 
    \'output_buf': repeat([' '], &columns * &lines),
	\'x_offset': &columns - a:te_tab.width / 2,
	\'y_offset': &lines - a:te_tab.height / 2
  \}

  function! renderer.render_ch()

  endfunction

  function! renderer.render_str(a:str)
    for ch in split(a:str, '\zs')
      call self.draw_ch(ch)
    endfor
  endfunction

endfunction

function! TE_Initialize()
  " clear options

endfunction

" let game_tab = TE_CreateTab()
" let game_renderer = TE_CreateRenderer()
" constructor --> input_handlers, assets, etc.
" let game = TE_Initialize(game_tab, game_renderer, constructor, loop, destructor)
" call game.run()

function! SetCh(x, y, ch, bg_fg_weight_group)
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
