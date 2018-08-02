function! te#CreateField(name, desired_num_ch_x, desired_num_ch_y)
  if &columns < a:desired_num_ch_x
    echomsg '[TE - Error] The maximum number of characters that can be ' .
	  \'currently displayed on a given row: ' . &columns . 
	  \' is less than the desired number: ' . a:desired_num_ch_x

	return v:none
  elseif &lines < a:desired_num_ch_y
    echomsg '[TE - Error] The maximum number of characters that can be ' .
	  \'currently displayed on a given column: ' . &lines . 
	  \' is less than the desired number: ' . a:desired_num_ch_y

	return v:none
  else
    execute 'edit ' . a:name

    return {
	  \'_num_ch_x': a:desired_num_ch_x,
	  \'_num_ch_y': a:desired_num_ch_y,
	  \'_offset_x': (&columns - a:desired_num_ch_x) / 2,
	  \'_offset_y': (&lines - a:desired_num_ch_y) / 2
    \}
  endif
endfunction

function! te#CreateRenderer(field)
  setlocal buftype=nofile
  setlocal nocursorcolumn
  setlocal nocursorline
  setlocal noerrorbells
  setlocal novisualbell
  setlocal mouse=a
  setlocal textwidth=1000000000000000

  let renderer = { 
	\'_field': a:field,
    \'_output_buf': repeat([' '], &columns * &lines),
	\'_format': {
	  \'_bg_fg_weight_groups': [],
	  \'_matches': {}
	\}
  \}

  function! renderer.destroy()
    for match_pattern in self._format._matches
	  call matchdelete(self._format._matches[match_pattern]['_id']) 	
	endfor
  endfunction

  function! renderer.set_ch(x, y, ch, bg_fg_weight_group)
    if a:x < 0 || a:x >= self._field._num_ch_x || 
	  \a:y < 0 || a:y >= self._field._num_ch_y
	  echomsg '[TE - Error] Invalid renderer output buffer coordinate: (' . 
	    \a:x . ', ' . a:y . ')'
	else
      let match_pattern = '' . a:x . '_' . a:y

      if has_key(self._format._matches, match_pattern)
        if self._format._matches[match_pattern]['_bg_fg_weight_group'] !=# a:bg_fg_weight_group
		  call matchdelete(self._format._matches[match_pattern]['_id'])
	    endif
	  endif

      if index(self._format._bg_fg_weight_groups, a:bg_fg_weight_group) < 0
        let [bg_color, fg_color, weight] = split(a:bg_fg_weight_group, '_')
        execute 'highlight ' . a:bg_fg_weight_group . ' ctermbg=' . bg_color .' guibg=' . bg_color . 
	    \' ctermfg=' . fg_color . ' guifg='. fg_color . ' cterm=' . weight .
	    \' gui=' . weight
	    call add(self._format._bg_fg_weight_groups, a:bg_fg_weight_group)
      endif

      let match_id = matchaddpos(a:bg_fg_weight_group, [a:x, a:y])
      let self._format._matches[match_pattern] = {
	    \'_id': match_id,
	    \'_bg_fg_weight_group': a:bg_fg_weight_group
      \}

	  let output_buf_index = (a:y + self._field._offset_y) * &columns + 
	    \(a:x + self._field._offset_x)
	  echo 'buf_index: ' . output_buf_index
      let self._output_buf[output_buf_index] = a:ch
	endif
  endfunction

  function! renderer.set_str(x, y, str, bg_fg_weight_group)
    let cur_ch_x_pos = a:x
    for ch in split(a:str, '\zs')
      call self.set_ch(cur_ch_x_pos, a:y, ch, a:bg_fg_weight_group)
	  let cur_ch_x_pos = cur_ch_x_pos + 1
    endfor
  endfunction

  function! renderer.render()
    let cur_line_num = 0 
	let prev_start_buf_index = 0
	while cur_line_num < &lines
	  let start_buf_index = prev_start_buf_index + (cur_line_num * &lines)
	  let end_buf_index = start_buf_index + &columns - 1
	  let prev_start_buf_index = start_buf_index
	  call setline(
	         \cur_line_num + 1, 
	         \join(self._output_buf[start_buf_index:end_buf_index], '')
	       \)
      let cur_line_num = cur_line_num + 1
	endwhile
  endfunction

  return renderer
endfunction
