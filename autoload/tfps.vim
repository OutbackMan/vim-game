" use ch_open("server:port")
" apply colouring to line ranges
" highlight FleetingFlashyFiretrucks ctermfg=red
" match FleetingFlashyFiretrucks /\%>2l\%<6l/

function! EnsureViewportIsLargeEnough(desired_width, desired_height)
  if &lines < a:desired_height
    echoerr '[TFPS] Current maximum viewport height of ' . &lines . ' is less than required minimum viewport height of ' . a:desired_height
  elseif &columns < a:desired_width
    echoerr '[TFPS] Current maximum viewport width of ' . &columns . ' is less than required minimum viewport width of ' . a:desired_width
  else
    return
  endif
endfunction

function! SetRequiredVimOptions()
  setlocal buftype=nofile
  setlocal nocursorcolumn
  setlocal nocursorline
  setlocal noerrorbells
  setlocal novisualbell
  setlocal mouse=a
endfunction

function! CreatePlayer(start_x, start_y, start_view_angle, fov)
  return {
    \'start_x': a:start_x,
	\'start_y': a:start_y,
	\'start_view_angle': a:start_view_angle,
	\'fov': a:fov
  \}
endfunction

function! CreateMap()
  return {
    \'width': 16,
	\'height': 16,
	\'field': '################
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

let g:counter = 0
function! Loop(viewport_width, viewport_height, map, player)
  call setline(line('$'), '' . g:counter . ' ' . a:player.start_x)
  let g:counter = g:counter + 1
endfunction

function! tfps#TFPS()
  let viewport_width = 120
  let viewport_height = 40

  call EnsureViewportIsLargeEnough(viewport_width, viewport_height)

  tabnew TFPS 

  call SetRequiredVimOptions()

  let player = CreatePlayer(0, 0, 0, 3.141 / 4.0)
  let map = CreateMap()

  " call RegisterInputMappings()

  let TFPSLoop = {-> Loop(viewport_width, viewport_height, map, player)}
  let g:tfps_loop_id = timer_start(0, TFPSLoop, {'repeat': -1})

  augroup EventListeners
    autocmd!
    autocmd BufLeave * :call timer_stop(tfps_loop_id)
  augroup END

endfunction
