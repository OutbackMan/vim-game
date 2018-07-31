
  let col = 0
  while col < a:renderer.field_width 
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
	    a:renderer.set_buf(row, col, ' ')
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
