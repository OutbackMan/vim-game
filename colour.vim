function! te#CreateField(name, desired_num_ch_x, desired_num_ch_y)
  if &columns < a:desired_num_ch_x
    echomsg '[TE - Error] The maximum number of characters that can be currently displayed on a given row: ' . &columns . 
	  \' is less than the desired number: ' . a:desired_num_ch_x

	return v:none
  elseif &lines < a:desired_num_ch_y
    echomsg '[TE - Error] The maximum number of characters that can be currently displayed on a given column: ' . &lines . 
	  \' is less than the desired number: ' . a:desired_num_ch_y

	return v:none
  else
    tabnew a:name

    return {
	  \'_num_ch_x': a:desired_num_ch_x,
	  \'_num_ch_y': a:desired_num_ch_y,
	  \'_x_offset': &columns - a:desired_num_ch_x / 2,
	  \'_y_offset': &lines - a:desired_num_ch_y / 2
    \}
  endif
endfunction

" Cyan_Red_bold/NONE"
function! te#CreateRenderer(field, default_ch, default_bg_fg_weight_group)
  call s:_ApplyVimScriptOptions()

  let renderer = { 
	\'_field': a:field,
    \'_output_buf': repeat([' '], &columns * &lines),
	\'_format': {
	  \'_bg_fg_weight_groups': [],
	  \'_matches': {}
	\}
  \}

  if a:default_bg_fg_weight_group == "none"
  " set up default 

  function! renderer.destructor()
    " remove matches and highlights
  endfunction

  function! renderer.set_ch(x, y, ch, bg_fg_weight_group)

  endfunction

  function! renderer.set_str(x, y, str, bg_fg_weight_group)
    for ch in split(a:str, '\zs')
      call self.set_ch(a:x, a:y, ch, a:bg_fg_weight_group)
    endfor
  endfunction

 function! renderer.render()
   let cur_line_num = 0 
	 while cur_line_num < &lines
	   let start_buf_index = cur_line_num * &lines 
	   let end_buf_index = start_buf_index + &columns
	   call setline(
	          \line(cur_line_num), 
		      \join(self._output_buf[start_buf_index:end_buf_index], '')
	        \)
       let cur_line_num = cur_line_num + 1
	endwhile
 endfunction

 return renderer
endfunction


" let game_field = TE_CreateTab()
" let game_renderer = TE_CreateRenderer()
" function! MyLoop() endfunction
" destructor() --> loop and renderer

format = {
    'style_groups': [],
	'patterns': {
	  '0,1': format.style_groups[0],
	}
}

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
