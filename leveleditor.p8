pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
--level editor test thing
--yolwoocle & gouspourd

function _init()
	mode = "edit" 
 init_player()
	cu_x,cu_y=0,0

end

function _update60()
 update_mouse()
 update_player()
 placeitem()
	if mode == "edit" then	
	elseif mode == "game" then
	end
	-- world to string
	if btn(🅾️) then
	a=""
	 for y =0,16 do
	 	for x = 0,16 do
	 		a=a..chr(mget(x,y)+32)
			end
  end
	end
end

function _draw()

 cls()
	map()
	draw_mouse()
	spr(64,p.x,p.y)
	print(a,0,0)
end

-->8
function update_mouse()
 poke(0x5f2d, 1)
 mouse_x=stat(32)
 mouse_y=stat(33)
 mouse_btn=stat(34)
 grid_x = mouse_x\8*8
 grid_y = mouse_y\8*8
 roll = stat(36)
 mousemap_x = mouse_x/8
 mousemap_y = mouse_y/8
end

function draw_mouse()
	spr(3,grid_x,grid_y)
	spr(2,mouse_x,mouse_y)
end
-->8
block_list={1,16,17}

function placeitem()

 --roll in item list
	if roll !=0 then
	 nb_blockselected=(nb_blockselected+roll)%#block_list
	 blockselected_in_liste()
	end
	
	-- blocktoplace
	if mouse_btn==2 then
	 -- erased
	 blocktoplace = 0
	 
	elseif mouse_btn==1 then
	 -- block selected
	 blocktoplace = blockselected
	 
	elseif mouse_btn==4 then
	 -- short cut
		block = mget(mousemap_x,mousemap_y)
		
		for i=1,#block_list do
		 if block == block_list[i] then
		 	nb_blockselected = i-1
		 	blockselected_in_liste()
		 end
		end
	end
	--block placement
 if mouse_btn != 0 and mouse_btn != 4 then
 	mset(mousemap_x,mousemap_y,blocktoplace)
 end
end

function blockselected_in_liste()
 blockselected = block_list[nb_blockselected+1]
end

-->8
--player

function init_player()
	p={
	 x=64,y=64,
	 dx=0,dy=0,
	 
	 spd=.4,
	 fric=.75,
	 
	 spr=64,
	 bw=6,bh=6,
	 bx=1,by=1,
	}
	blockselected=block_list[1]
	nb_blockselected=0
end

function update_player()
	spd=p.spd
	if (btn(⬅️)) p.dx-=spd
	if (btn(➡️)) p.dx+=spd
	if (btn(⬆️)) p.dy-=spd
	if (btn(⬇️)) p.dy+=spd
	
	p.dx *= p.fric
	p.dy *= p.fric
	
	collide(p)
	
	p.x += p.dx
	p.y += p.dy
end

function is_solid(x,y)
	return fget(mget(x\8,y\8),0)
end

function collision(x,y,w,h,flag)
	return 
	   is_solid(x,  y)
	or is_solid(x+w,y)
	or is_solid(x,  y+h)
	or is_solid(x+w,y+h) 
end

function collide(o)
	local x,y = o.x,o.y
	local dx,dy = o.dx,o.dy
	local w,h = o.bw,o.bh
	local ox,oy = x+o.bx,y+o.by
	local bounce = 0.1
	
	--collisions
	local e = 1
	local coll_x = collision( 
	ox+dx, oy,    w-e, h-e)
	local coll_y = collision(
	ox,    oy+dy, w-e, h-e)
	local coll_xy = collision(
	ox+dx, oy+dy, w-e, h-e)
	
	if coll_x then
		o.dx *= -bounce
	end
	
	if coll_y then
		o.dy *= -bounce
	end
	
	if coll_xy and 
	not coll_x and not coll_y then
		--prevent stuck in corners 
		o.dx *= -bounce
		o.dy *= -bounce
	end
end

__gfx__
00000000050454000100000066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004444451710000060000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700044000401771000060000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000044000451777100060000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000544000401777710060000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700044444451771100060000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000444000117100060000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005005000000000066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d670076d0dddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000006d666666d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000007d6dddd6d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d6dddd6d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d6dddd6d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000007d6dddd6d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000006d666666d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d670076d0dddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3eeeeee3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3ee3e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3eeeeee3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33eeee33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3333e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3eeeeee3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666660100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000600000061710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700600000061771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000600000061777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000600000061777710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700600000061771100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000600000060117100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
