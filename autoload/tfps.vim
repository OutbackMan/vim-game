" use ch_open("server:port")
" apply colouring to line ranges

function! ViewportIsNotLargeEnough(desired_field_width, desired_field_height)
  if &lines < a:desired_field_height
    echoerr '[TFPS] Current maximum viewport height of ' . &lines . 
	  \' is less than required minimum viewport height of ' . a:desired_field_height
	return 1
  elseif &columns < a:desired_field_width
    echoerr '[TFPS] Current maximum viewport width of ' . &columns . 
	  \' is less than required minimum viewport width of ' . a:desired_field_width
	return 1
  else
    return 0
  endif
endfunction

function! SetRequiredVimOptions()
  setlocal buftype=nofile
  setlocal nocursorcolumn
  setlocal nocursorline
  setlocal noerrorbells
  setlocal novisualbell
  setlocal mouse=a
  setlocal textwidth=&columns
endfunction

function! CreatePlayer(x, y, view_angle, fov)
  return {
    \'x': a:x,
	\'y': a:y,
	\'view_angle': a:view_angle,
	\'fov': a:fov
  \}
endfunction

function! CreateMap()
  return {
    \'width': 16,
	\'height': 16,
	\'depth': 16,
	\'content': '################
	            \#..............#
	            \#..............#
	            \#..............#
	            \#..............#
	            \#..............#
	            \#..............#
	            \#..............#
	            \#..............#
	            \#..............#
	            \#..............#
	            \#..............#
	            \#..............#
	            \#..............#
	            \#..............#
	            \################'
  \}
endfunction

function! CreateRenderer(field_width, field_height, default_char, default_bg_colour, default_fg_color)
  execute 'highlight DefaultCh ctermfg=' . a:default_fg_color . 
    \' guifg=' . a:default_fg_color . ' ctermbg=' . a:default_bg_color .
	\' guibg='. a:default_bg_color

  match DefaultCh /.*/

  let renderer = { 
    \'buf': repeat([a:bg_char], &columns * &lines),
	\'field_width': a:field_width,
	\'field_height': a:field_height,
	\'x_offset': &columns - a:field_width / 2,
	\'y_offset': &lines - a:field_height / 2
  \}

  function! renderer.set_buf(x, y, ch)
    if a:x < 0 || a:x >= self.field_width || a:y < 0 || a:y >= self.field_height
		echoerr 'Invalid renderer buffer coordinate: (' . a:x . ', ' . a:y . ')'
	else
      self.buf[(a:y + self.y_offset) * &columns + (a:x + self.x_offset)] = a:ch
	endif
  endfunction

  function! renderer.render()
    let cur_line_num = 0 
	while cur_line_num < &lines
	  let start_buf_index = cur_line_num * &lines 
	  let end_buf_index = start_buf_index + &columns
	  setline(line(cur_line_num), join(self.buf[start_buf_index:end_buf_index], ''))
      let cur_line_num = cur_line_num + 1
	endwhile
  endfunction

  return renderer
endfunction

function! RegisterInputMappings(player)
  noremap <silent> <buffer> <LeftMouse> :echo 'clicked'<CR> " then read cursor position
  noremap <silent> <buffer> a :call RotateLeft(a:player)<CR>
  noremap <silent> <buffer> d :call RotateRight(a:player)<CR>
endfunction

function! RotateLeft(player)
  let a:player.view_angle = a:player.view_angle - 0.1
endfunction

function! RotateRight(player)
  let a:player.view_angle = a:player.view_angle + 0.1
endfunction

function! Loop(renderer, map, player)
 call a:renderer.render()
endfunction


function! tfps#TFPS()
  let field_width = 120
  let field_height = 40

  if ViewportIsNotLargeEnough(field_width, field_height)
    return
  endif

  tabnew TFPS 

  call SetRequiredVimOptions()

  let renderer = CreateRenderer(field_width, field_height)
  let map = CreateMap()
  let player = CreatePlayer(8.0, 8.0, 0, 3.141 / 4.0)

  call RegisterInputMappings(player)

  let TFPSLoop = {-> Loop(renderer, map, player)}
  let g:tfps_loop_id = timer_start(0, TFPSLoop, {'repeat': -1})

  augroup EventListeners
    autocmd!
    autocmd BufLeave * :call timer_stop(tfps_loop_id)
  augroup END

endfunction
