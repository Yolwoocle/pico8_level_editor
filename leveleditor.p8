pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
--level editor test thing
--yolwoocle & gouspourd

function _init()
	mode = "edit" 
	switch = true
	nb11 = 1
	xstart,ystart=64,64
	init_cursor()
	init_player()
	init_hotbar()
	editmapcd = 0
end

function _update60()
	if mode == "edit" then
		update_cursor()
		editmap()

		-- exporting/importing
		if btn(⬆️) then
			printh(wd_str(),'@clip')
		end
	
		if btn(⬇️)then
			wd_passt(stat(4))
		end
		
		if btnp(❎) then 
			mode="play"
			parse_level()
			init_player()
		end
		
		update_btns(hotbar)
		
	elseif mode == "play" then
		update_player()
		update_objs()
		if(btnp(❎))mode="edit" wd_passt(wd)
	end
	
end

function _draw()
	cls()
	map()
	color(7)
	--print("debug:"..tostr(debug),0,16)
	spr(16,(p.x+4)\8*8,(p.y+4)\8*8)
	if mode == "edit" then
		draw_btns(hotbar)
		--no code below this
		draw_cursor()
	elseif mode == "play" then
		spr(64,p.x,p.y)
		draw_objs()
	end
end

--functions

function abtn(b)
	return btn(b) or btn(b,1)
end

function sgn(n)
	if(n==nil)return nil
	if(n<0)return -1
	if(n>0)return 1
	return 0
end

function v(x,y)
	return {x=x,y=y}
end
-->8
--mouse & cursor
function init_cursor()
	cui = 1
	cusel = 1
	prevcux = 1
	prevcuy = 1
	cux = 0
	cuy = 0
	prevlmb = false
	prevo = false
	btno = false
end

function update_cursor()
	poke(0x5f2d, 1)
	mx=stat(32)
	my=stat(33)
	prevlmb = lmb
	lmb=stat(34)&1>0
	rmb=stat(34)&2>0
	mmb=stat(34)&4>0
	mscrl = stat(36)
	cux = mx\8
	cuy = my\8
	
	grid_x = cux*8
	grid_y = cuy*8
end

function draw_cursor()
	spr(16,grid_x,grid_y)
	spr(17,mx,my)
	
	spr(cusel,mx+4,my+4)
end
-->8
--level editing & processing
 
block_list={1,2,3,4,5,6,7,8,9,10,11}

function parse_level()
	objects = {}
	wd = wd_str()
	for y=0,15 do
		for x=0,15 do
			local m=mget(x,y)
			if fget(m,1) then
				add(objects,make_ball(x*8,y*8))
				mset(x,y,0)
			elseif m==32 then
				mset(x,y,0)
			end

		end
	end
end

function editmap()
	--roll in item list
	--editmapcd = max(0,editmapcd-1)
	if mscrl !=0 then
		cui += mscrl
		cui %= #block_list
		if(cui<=0)cui = #block_list
		update_sel()
	end
	--if editmapcd == 0 then
	blocktoplace = nil
	if lmb then
		-- block selected
		blocktoplace = cusel
		
	elseif rmb then
		-- erasing
		blocktoplace = 32
		
	elseif mmb then
		-- short cut
		block = mget(cux,cuy)
		
		for i=1,#block_list do
			if block == block_list[i] then
				cui = i
				update_sel()
			end
		end
	end
	
	--block placement
	if blocktoplace and (not(prevlmb) or (prevcux != cux or prevcuy != cuy)) then
	 bktoreplace = mget(cux,cuy)
	 
	 replaceby(2,5,18)
	 
	 replaceby(3,5,19)
	 
	 replaceby(4,5,20)
	 if blocktoplace != 11 or 	nb11 > 0 then
		mset(cux,cuy,blocktoplace)
		if (bktoreplace == 11) nb11 += 1 xstart=64 ystart=64
		if (blocktoplace == 11) nb11 -= 1 xstart=cux*8 ystart=cuy*8
		end
		prevcux = cux
	 prevcuy = cuy
		--editmapcd = 4
	end
	--end 
end

function replaceby(nbktoplce,nbktorep,newblock)
if blocktoplace == nbktoplce
	 and bktoreplace == nbktorep then 
	 blocktoplace = newblock
	end
end 

function update_sel()
	cusel = block_list[cui]
end

function wd_str()
a=""
	for y =0,16 do
		for x = 0,16 do
			a=a..chr(mget(x,y)+34)
		end
	end
return a
end

function wd_passt(maptoprint)
local elt = 1
for y =0,16 do
		for x = 0,16 do
			mset(x,y,ord(sub(maptoprint,elt,elt))-34)
			elt += 1
		end
	end
end
-->8
--player

function init_player()
	p={
	 x=xstart,y=ystart,
	 dx=0,dy=0,
	 
	 bx=2,by=2,
	 bw=6,bh=6,
	 
	 g=0.3,
	 
	 spd=.4,
	 fric=.75,
	 
	 spr=64,
	 dashcd = 0,
	 activate = false,
	 cd = 0,
	 cdmax = 10,
	}
	--blockselected=block_list[1]
	--nb_blockselected=0
end

function update_player()
 p.cd = max(p.cd-1,0)
 p.dashcd = max(p.dashcd-1,0)
 p.activate = false
 if (p.dashcd > 11) p.activate = true
 prevo = btno
	btno = btn(🅾️)
	spd=p.spd
	if (p.dashcd==0 and btno and not(prevo)) spd = 4 p.dashcd = 20
	if (abtn(⬅️)) p.dx-=spd
	if (abtn(➡️)) p.dx+=spd
	if (abtn(⬆️)) p.dy-=spd
	if (abtn(⬇️)) p.dy+=spd
	
	
	p.dx *= p.fric
	p.dy *= p.fric
	
	collide(p)
	
	p.x += p.dx
	p.y += p.dy
end


-->8
--objects (+ collsion)
function make_ball(x,y)
	return {
		x=x, y=y,
		dx=0,dy=0,
		dir=v(0,0),
		spd=3,
		
		bx=1,by=1,
		bw=6,bh=6,
		
		spr=2,
		ghosttimer=0,
		kickable = true,
		activate = true,
		cd = 0,
		cdmax = 4,
	}
end

function update_objs()
	for o in all(objects)do
	o.cd = max(o.cd-1,0)
		o.x += o.dx
		o.y += o.dy
		local x=o.x
		local y=o.y
		
  o.kicked = not(kickable)
		
		o.ghosttimer -= 1
		
		o.debug=obj_coll(o,p)
		if o.kickable and obj_coll(o,p) then
			--determine kick axis
			local axis=v(2,0)
			if(abs(p.dy)>abs(p.dx))axis=v(0,2)
			
			
			o.kicked = true
			o.dx = sgn(p.dx)*axis.x
			o.dy = sgn(p.dy)*axis.y
			
			debug=tostr(o.dx).." "..tostr(o.dy)
			
		end
		collide(o,1)
--		if o.kicked then
--			if collide(o,1,true) then
--			interact_block(o,x+o.dx*3,y+o.dy*3)
--			end
--			
--		end
  if o.kicked then
		for i in all(objects)do
			if obj_coll(o,i) and 
			(i.x!=o.x or i.y!=o.y)then
				del(objects,o) 
				del(objects,i)
			end
		end
		end
		
		if x%8==0 and y%8==0 then 
			map_x = x/8
			map_y = y/8
			check = true
		else 
			check = false
		end
		if check then
			for i = -1,1,2 do
				if mget(map_x+i,map_y)==3 then

					o.dx = -i*2

					o.dy = 0
				end
			end
			for i = -1,1,2 do
				if mget(map_x,map_y+i)==4 then

					o.dx = 0
					o.dy = -i*2
				end
			end
			
		end
	end
end

--[[function interact_block(x,y,o)
	local x=x\8
	local y=y\8
	object = mget(x,y)
	if object == 5 then --chest
		mset(x,y,21)
		add(objects,make_ball(
		 (x+sgn(o.dx))*8,
		 (y+sgn(o.dy))*8
		))
	end
	if object == 7 then
		mset(x,y,0)
		del(objects,o)
	end
end]]

function draw_objs()
	for o in all(objects)do
		spr(o.spr,o.x,o.y)
	end
end


-- collisions
 
function is_solid(x,y,o)
	if fget(mget(x\8,y\8),0) then
	if (o.activate) interact_block(x,y,o)
	return true
	else
	return false
	end
end

function collision(x,y,w,h,o)
	return 
	   is_solid(x,  y,o)
	or is_solid(x+w,y,o)
	or is_solid(x,  y+h,o)
	or is_solid(x+w,y+h,o) 
end

function collide(o,bounce)
	local x,y = o.x,o.y
	local dx,dy = o.dx,o.dy
	local w,h = o.bw-1,o.bh-1
	local ox,oy = x+o.bx,y+o.by
	bounce = bounce or 0.01 
	activate = activate or false
	
	--collisions
	local coll_x = collision( 
	ox+dx, oy,    w, h,o)
	local coll_y = collision(
	ox,    oy+dy, w, h,o)
	local coll_xy = collision(
	ox+dx, oy+dy, w, h,o)
	
	local output = false
	if coll_x then
		o.dx *= -bounce
		output = true
	end
	
	if coll_y then
		o.dy *= -bounce
		output = true
	end
	
	if coll_xy and not output then
		--prevent stuck in corners 
		o.dx *= -bounce
		o.dy *= -bounce
		output = true
	end
	
	return output
end

function rect_overlap(ax,ay,
aw,ah,bx,by,bw,bh)
	return not (ax > bx+bw
	         or ay > by+bh
	         or ax+aw < bx
	         or ay+ah < by)
end

function point_rect_coll(x,y,x1,y1,w,h)
	return x1 <= x
	   and x1+w >= x
	   and y1 <= y
	   and y1+w >= y
end

function obj_coll(a,b)
	local ax = a.x+a.bx
	local ay = a.y+a.by
	
	local bx = b.x+b.bx
	local by = b.y+b.by
	
	return rect_overlap(
	ax, ay, a.bw, a.bh,
	bx, by, b.bw, b.bh
	)
end

function interact_block(x,y,o)
local x=x\8
local y=y\8
local cd = o.cd
	object = mget(x,y)
	stop_ = false
	for i = 1,7,3 do
	for k = 1,7,3 do
	local _mx = (o.x+i)\8
  local _my = (o.y+k)\8
  for a =-1,1 do
  for z =-1,1 do
  if not(stop_)and x+a == _mx and y+z == _my then
   if a+z == 1 or a+z == -1 then
   g = -a
   h = -z
   stop_ = true
   end
  end
  end
  end
  end
  end
  
	if cd == 0 then
	if object == 18 then
		mset(x,y,21)
		add(objects,make_ball((x+g)*8,(y+h)*8))
	elseif object == 5 then
	mset(x,y,21)
	elseif object == 19 then
	mset(x,y,21)
	mset(x+g,y+h,3)
 elseif object == 20 then
	mset(x,y,21)
	mset(x+g,y+h,4)
	elseif object == 7 then
		mset(x,y,0)
		del(objects,o)
	elseif object == 8 then
		mset(x,y,24)
  o.cd = o.cdmax
  switch = false
  updateswitch()
	elseif object == 24 then
		mset(x,y,8)
		o.cd = o.cdmax
		switch = true
		updateswitch()
	end
	end
end

function updateswitch()
		for y=0,15 do
		for x=0,15 do
		 if not(switch)then
		  if mget(x,y) == 8 then
		 	mset(x,y,24) 
		 	elseif mget(x,y) == 9 then
		 	mset(x,y,25) 
		 	elseif mget(x,y) == 10 then
		 	mset(x,y,26) 
		 	end
		 elseif switch then
		 if mget(x,y) == 24 then
		 	mset(x,y,8) 
		 	elseif mget(x,y) == 26 then
		 	mset(x,y,10)
		 	elseif mget(x,y) == 25 then
		 	mset(x,y,9) 
		  end
   end
		end
		end
end

-->8
--ui
function make_button(n,x,y,w,h,sp,txt,onclick)
	return {
		n=n,
		x=x, y=y,
		w=w, h=h,
		sp=sp,
		txt=txt,
		
		hovered=false,
		onclick=onclick,
	}
end

function update_btns(btns)
	for b in all(btns)do
		if point_rect_coll(mx,my,b.x,b.y,b.w,b.h) then
			b.hovered = true
			if lmb then
				b:onclick()
			end
		end
		
		if my<30 then
			b.y+=(-9-b.y)/6
		else
			b.y+=(2-b.y)/6
		end
	end
end

function draw_btns(btns)
	for b in all(btns)do
		local x,y,w,h=b.x,b.y,b.w,b.h
		rectfill(x,y,x+w,y+h,1)
		spr(b.sp,x+1,y+1)
		if(b.n==cui)rect(x,y,x+w,y+h,7)
	end
end

---

function init_hotbar()
	hotbar={}
	for i=1,14 do
		add(hotbar, make_button(i,
		-8+9*i, 2,
		9,9,i,"lol",sgn))
	end
end
__gfx__
000000000dddddd000000000e20000e2e88888827fffffff008822000dddddd09aaaaaaa099999900cccccc00000000000000000000000000000000000000000
00000000d666666d00bbb3008207708222222222faaaaaa408888ee0d656665da999999494444449c000000c0033330000000000000000000000000000000000
00700700d6dddd6d0b3b3bb08270078200700700faa999a408e2822055d5d55da999999494999949c000000c033bb33000000000000000000000000000000000
00077000d6dddd6d03b3b7708200008207000070fa9aa99408e28ee0d6d55d6da999999494999949c000000c03bbbb3000000000000000000000000000000000
00077000d6dddd6d7bb376678200008207000070faaa99a408e28220d6dd5d6da999999494999949c000000c03bbbb3000000000000000000000000000000000
00700700d6dddd6d677761168270078200700700faaaaaa408e28220d655556da999999494999949c000000c033bb33000000000000000000000000000000000
00000000d666666d066611f082077082e8888882faaa99a408888220d656656da999999494444449c000000c0033330000000000000000000000000000000000
000000000dddddd000ffff002200002222222222a444444400882200055dd55074444444099999900cccccc00000000000000000000000000000000000000000
d677776d0100000011111fff11111fff11111fff799999990000000000000000cddddddd099999900cccccc00000000000000000000000000000000000000000
600000061710000011b11aa418181aa418881aa4944444450000000000000000dcccccc190000009c111111c0000000000000000000000000000000000000000
70000007177100001b3319a4187819a4117119a4944444450000000000000000dcccccc190000009c1cccc1c0000000000000000000000000000000000000000
70000007177710001fff19941818199418881994944444450000000000000000dcccccc190000009c1cccc1c0000000000000000000000000000000000000000
7000000717777100111119a4111119a4111119a4944444450000000000000000dcccccc190000009c1cccc1c0000000000000000000000000000000000000000
7000000717711000faaaaaa4faaaaaa4faaaaaa4944444450000000000000000dcccccc190000009c1cccc1c0000000000000000000000000000000000000000
6000000601171000faaa99a4faaa99a4faaa99a4944444450000000000000000dcccccc190000009c111111c0000000000000000000000000000000000000000
d677776d00000000a4444444a4444444a444444445555555000000000000000071111111099999900cccccc00000000000000000000000000000000000000000
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0001020000010001010100000000000000000101010100000100010000000000000000000001000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001c0501c0501c0501c0501c0501c0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
