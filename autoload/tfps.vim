" use ch_open("server:port")
" apply colouring to line ranges
" highlight FleetingFlashyFiretrucks ctermfg=red
" match FleetingFlashyFiretrucks /\%>2l\%<6l/

function! ViewportIsNotLargeEnough(desired_width, desired_height)
  if &lines < a:desired_height
    echoerr '[TFPS] Current maximum viewport height of ' . &lines . 
	  \' is less than required minimum viewport height of ' . a:desired_height
	return 1
  elseif &columns < a:desired_width
    echoerr '[TFPS] Current maximum viewport width of ' . &columns . 
	  \' is less than required minimum viewport width of ' . a:desired_width
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

function! RegisterInputMappings()
  noremap <silent> <buffer> a :call RotateLeft()<CR>
  noremap <silent> <buffer> d :call RotateRight()<CR>
endfunction

function! RotateLeft()
  let a:player.view_angle = a:player.view_angle - 0.1
endfunction

function! RotateRight()
  let a:player.view_angle = a:player.view_angle + 0.1
endfunction

function! Loop(viewport_width, viewport_height, map, player)
  let col = 0
  while col < a:viewport_width
	let ray_angle = (a:player.view_angle - (a:player.fov / 2.0)) + ((col / a:viewport_width) * a:player.fov)

    let distance_to_wall = 0 
	let have_not_hit_wall = 1

	let ray_x = sin(ray_angle)
	let ray_y = cos(ray_angle)

    while have_not_hit_wall && distance_to_wall < a:player.depth
      let distance_to_wall = distance_to_wall + 0.1
	  
	  let ray_segment_x = a:player.x + ray_x * distance_to_wall
	  let ray_segment_y = a:player.y + ray_y * distance_to_wall

      if ray_segment_x < 0 || ray_segment_x >= a:viewport_width || ray_segment_y < 0 || ray_segment_y >= a:viewport_height
        let have_not_hit_wall = 0
		let distance_to_wall = a:player.depth
	  else
	    if a:map[ray_segment_x * a:map.width + ray_segment_y] == '#'
          let have_not_hit_wall = 0
		endif
	  endif
    endwhile

    let ceiling = a:viewport_height / 2.0 - a:viewport_height / distance_to_wall
	let floor = a:viewport_height - ceiling

    let row = 0
	while row < a:viewport_height
      if row < ceiling
	    screen[row * a:viewport_width + col] = ' '; 
	  elseif row > ceiling && row <= floor
	    screen[row * a:viewport_width + col] = '#'; 
	  else
	    screen[row * a:viewport_width + col] = '.'; 
	  endif
    let row = row + 1
	endwhile
    
    let col = col + 1
  endwhile
  " call setline(line('$'), '' . g:counter . ' ' . a:player.start_x)
endfunction

function! CreateRenderer(field_width, field_height)
  let renderer = { 
    \'buffer': repeat([" "], &columns * &lines),
	\'field_width': a:field_width,
	\'field_height': a:field_height
  \}

  function! renderer.set(x, y, ch)
    let x_offset = &columns - self.field_width / 2
    let y_offset = &rows - self.field_height / 2
    if a:x + x_offset < 0 || a:x + x_offset >= self.field_width || a:y + y_offset .....
		echoerr "invalid coordinate"
	else
      self.buffer[(a:y + y_offset) * &columns + a:x + x_offset] = a:ch
	endif
  endfunction

  function! renderer.render()
    let line_num = 0 
	while line_num < &lines
	  let start_index = line_num * &lines 
	  let end_index = start_index + &columns
	  setline(line(line_num), join(self.buffer[start_index:end_index], ''))
      let line_num = line_num + 1
	endwhile
  endfunction

  return renderer
endfunction

function! tfps#TFPS()
  let output_width = 120
  let output_height = 40

  if ViewportIsNotLargeEnough(output_width, output_height)
    return
  endif

  tabnew TFPS 

  call SetRequiredVimOptions()

  let renderer = CreateRenderer(output_width, output_height)
  let player = CreatePlayer(8.0, 8.0, 0, 3.141 / 4.0)
  let map = CreateMap()

  call RegisterInputMappings()

  let TFPSLoop = {-> Loop(viewport_width, viewport_height, map, player)}
  let g:tfps_loop_id = timer_start(0, TFPSLoop, {'repeat': -1})

  augroup EventListeners
    autocmd!
    autocmd BufLeave * :call timer_stop(tfps_loop_id)
  augroup END

endfunction
