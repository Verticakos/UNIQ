--[[ UNIQ V25 — COMPLETE ]]
local Players=game:GetService("Players") local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService") local TweenService=game:GetService("TweenService")
local CoreGui=game:GetService("CoreGui") local Lighting=game:GetService("Lighting")
local HttpService=game:GetService("HttpService") local TeleportService=game:GetService("TeleportService")
local Camera=workspace.CurrentCamera local player=Players.LocalPlayer local UIS=UserInputService

if _G.UniqShutdown then pcall(_G.UniqShutdown) _G.UniqShutdown=nil end
local GEN=(_G.UniqGen or 0)+1 _G.UniqGen=GEN
local oldPrev=CoreGui:FindFirstChild("UniqPreview") if oldPrev then oldPrev:Destroy() end
if _G.UniqFovDrawing then pcall(function() _G.UniqFovDrawing:Remove() end) _G.UniqFovDrawing=nil end

local SCRIPT_URL = "https://raw.githubusercontent.com/Verticakos/UNIQ/refs/heads/main/UNIQ.lua"

local function httpGet(url) local req=(request or http_request or (syn and syn.request) or (fluxus and fluxus.request)) if req then local ok,r=pcall(req,{Url=url,Method="GET"}) if ok and r and r.Body then return r.Body end end if game.HttpGet then local ok,r=pcall(function() return game:HttpGet(url) end) if ok then return r end end return nil end

local state={walkSpeedEnabled=false,walkSpeedMultiplier=1.0,flyEnabled=false,flySpeed=300,jumpEnabled=false,jumpHeight=7.2,noJumpCooldown=false,infiniteJump=false,autoJump=false,noRagdoll=false,highGrav=false,noclip=false,visualMaxDistance=500,selectedPlayer=nil,selectedStaff=nil,menuKey=Enum.KeyCode.RightShift,autoReattach=true,aimbotEnabled=false,aimbotFov=120,aimbotSmoothX=10,aimbotSmoothY=10,aimbotTargetPart="Head",showFov=false,aimbotKey=nil,aimbotActivation="Hold",aimbotToggled=false,aimMinDist=1,aimMaxDist=500,aimbotIgnoreDead=false,ignoreFriend=false,friends={},aimMethod="Camera"}

local walkConn,noclipConn,flyConn,renderConn,charConn,flyB,flyE,jumpConn,autoJumpConn,aimbotConn,antiAFKConn
local staffA,staffR,visA,visR local flying=false local originalCollision={}
local controls={forward=0,backward=0,left=0,right=0,up=0,down=0}
local flyKeyMap={[Enum.KeyCode.W]="forward",[Enum.KeyCode.S]="backward",[Enum.KeyCode.A]="left",[Enum.KeyCode.D]="right",[Enum.KeyCode.Space]="up",[Enum.KeyCode.LeftControl]="down"}

local function effMult() local m=state.walkSpeedMultiplier or 1 if m<=1 then return 1 end return 1+((m-1)*(9/49)) end
local function applyWalkSpeed() local c=player.Character if not c then return end local h=c:FindFirstChildOfClass("Humanoid") local r=c:FindFirstChild("HumanoidRootPart") if not h or not r then return end h.WalkSpeed=16 if walkConn then walkConn:Disconnect() walkConn=nil end if state.walkSpeedEnabled and state.walkSpeedMultiplier>1 then walkConn=RunService.Heartbeat:Connect(function() local c2=player.Character if not c2 or flying or not state.walkSpeedEnabled then return end local h2=c2:FindFirstChildOfClass("Humanoid") local r2=c2:FindFirstChild("HumanoidRootPart") if not h2 or not r2 then return end local md=h2.MoveDirection if md.Magnitude>0 then local em=effMult() r2.AssemblyLinearVelocity=Vector3.new((md*(16+16*(em-1)*8)).X,r2.AssemblyLinearVelocity.Y,(md*(16+16*(em-1)*8)).Z) else local cv=r2.AssemblyLinearVelocity r2.AssemblyLinearVelocity=Vector3.new(cv.X*0.02,cv.Y,cv.Z*0.02) end end) else r.AssemblyLinearVelocity=Vector3.new(0,r.AssemblyLinearVelocity.Y,0) end end
local function applyJump() local c=player.Character if not c then return end local h=c:FindFirstChildOfClass("Humanoid") if not h then return end h.UseJumpPower=false h.JumpHeight=state.jumpEnabled and state.jumpHeight or 7.2 end
task.spawn(function() while _G.UniqGen==GEN do task.wait(0.07) local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") if h and h.Health>0 then if state.jumpEnabled then applyJump() end if state.infiniteJump and h.FloorMaterial==Enum.Material.Air and UIS:IsKeyDown(Enum.KeyCode.Space) then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end end)
local lastNCJ=0
task.spawn(function() while _G.UniqGen==GEN do task.wait() if state.noJumpCooldown then local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") if h and h.Health>0 and h.FloorMaterial~=Enum.Material.Air and UIS:IsKeyDown(Enum.KeyCode.Space) then local now=tick() if now-lastNCJ>0.6 then lastNCJ=now h:ChangeState(Enum.HumanoidStateType.Jumping) end end end end end)
jumpConn=UIS.JumpRequest:Connect(function() if state.infiniteJump then local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h and h.Health>0 then h:ChangeState(Enum.HumanoidStateType.Jumping) h.Jump=true end end end)
autoJumpConn=RunService.Heartbeat:Connect(function() if state.autoJump then local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h and h.Health>0 and h.FloorMaterial~=Enum.Material.Air then h:ChangeState(Enum.HumanoidStateType.Jumping) h.Jump=true end end end)

-- AIMBOT
local fovDrawing=Drawing.new("Circle") fovDrawing.Visible=false fovDrawing.Filled=false fovDrawing.Thickness=1 fovDrawing.Color=Color3.fromRGB(0,166,255) fovDrawing.NumSides=64
_G.UniqFovDrawing=fovDrawing
local function isAimKeyDown() local k=state.aimbotKey if not k then return false end if typeof(k)=="EnumItem" then if k.EnumType==Enum.KeyCode then return UIS:IsKeyDown(k) elseif k.EnumType==Enum.UserInputType then return UIS:IsMouseButtonPressed(k) end end return false end
aimbotConn=RunService.RenderStepped:Connect(function()
	if state.showFov then fovDrawing.Visible=true fovDrawing.Radius=state.aimbotFov fovDrawing.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2) else fovDrawing.Visible=false end
	if not state.aimbotEnabled then return end
	local active if state.aimbotActivation=="Toggle" then active=state.aimbotToggled else active=isAimKeyDown() end
	if not active then return end
	local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
	local best,bestDist=nil,state.aimbotFov
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr~=player and plr.Character then
			local isFr=state.friends[plr.Name] or state.friends[tostring(plr.UserId)]
			if not (state.ignoreFriend and isFr) then
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
							if on then local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude if d<bestDist then bestDist=d best=aimPos end end
						end
					end
				end
			end
		end
	end
	if best then
		if state.aimMethod=="Camera" then
			local camPos=Camera.CFrame.Position local cur=Camera.CFrame.LookVector
			local target=(best-camPos).Unit
			local ax=1/math.clamp(state.aimbotSmoothX,1,100) local ay=1/math.clamp(state.aimbotSmoothY,1,100)
			local mixed=Vector3.new(cur.X+(target.X-cur.X)*ax,cur.Y+(target.Y-cur.Y)*ay,cur.Z+(target.Z-cur.Z)*ax).Unit
			Camera.CFrame=CFrame.new(camPos,camPos+mixed)
		elseif state.aimMethod=="MouseMoveRel" then
			local sp,on=Camera:WorldToViewportPoint(best)
			if on and mousemoverel then
				local dx=(sp.X-center.X)/math.clamp(state.aimbotSmoothX,1,100)
				local dy=(sp.Y-center.Y)/math.clamp(state.aimbotSmoothY,1,100)
				pcall(mousemoverel,dx,dy)
			end
		elseif state.aimMethod=="Silent" then
			local camPos=Camera.CFrame.Position
			Camera.CFrame=CFrame.new(camPos,best)
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
local function getSelPlayers() local l={} for _,p in ipairs(Players:GetPlayers()) do if p~=player then table.insert(l,p.Name) end end table.sort(l) return l end
local function findP(name) if not name or name=="None" then return nil end for _,p in ipairs(Players:GetPlayers()) do if p.Name==name then return p end end return nil end
local function tpToSel() local t=findP(state.selectedPlayer) local tH=t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") local h=player.Character and player.Character:FindFirstChild("HumanoidRootPart") if h and tH then h.CFrame=tH.CFrame+Vector3.new(0,0,3) end end
local function specByName(name) local t=findP(name) local hum=t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") if hum then workspace.CurrentCamera.CameraSubject=hum end end
local function stopSpec() local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if hum then workspace.CurrentCamera.CameraSubject=hum end end

-- ============ FLING (REWRITTEN — alternating velocity method) ============
local flingActive=false
local flingSavedCF=nil

local function stopFling()
	flingActive=false
	task.wait(0.1)
	local c=player.Character
	if c then
		local hrp=c:FindFirstChild("HumanoidRootPart")
		local hum=c:FindFirstChildOfClass("Humanoid")
		if hrp then
			hrp.Velocity=Vector3.zero
			hrp.RotVelocity=Vector3.zero
			hrp.AssemblyLinearVelocity=Vector3.zero
			hrp.AssemblyAngularVelocity=Vector3.zero
			if flingSavedCF then hrp.CFrame=flingSavedCF end
		end
		if hum then hum.Sit=false hum.PlatformStand=false end
	end
	flingSavedCF=nil
end

local function flingSelected()
	if flingActive then stopFling() return end
	local targetName=state.selectedPlayer
	if not targetName or targetName=="None" then warn("[UNIQ] Select a player first") return end
	local target=findP(targetName)
	if not target then warn("[UNIQ] Target not found") return end

	local c=player.Character
	if not c then return end
	local hrp=c:FindFirstChild("HumanoidRootPart")
	local hum=c:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	flingSavedCF=hrp.CFrame
	flingActive=true

	task.spawn(function()
		local startTime=tick()
		while flingActive and tick()-startTime<5 do
			local ch=player.Character
			if not ch then break end
			local root=ch:FindFirstChild("HumanoidRootPart")
			if not root then break end
			local tc=target.Character
			if not tc then break end
			local tr=tc:FindFirstChild("HumanoidRootPart") or tc:FindFirstChild("Torso") or tc:FindFirstChild("UpperTorso")
			if not tr then break end

			-- Phase 1: above target with positive velocity
			root.CFrame=tr.CFrame*CFrame.new(0,1.5,0)
			root.Velocity=Vector3.new(9999,9999,9999)
			root.RotVelocity=Vector3.new(9999,9999,9999)
			RunService.Heartbeat:Wait()

			if not flingActive then break end
			ch=player.Character if not ch then break end
			root=ch:FindFirstChild("HumanoidRootPart") if not root then break end
			tc=target.Character if not tc then break end
			tr=tc:FindFirstChild("HumanoidRootPart") or tc:FindFirstChild("Torso") or tc:FindFirstChild("UpperTorso")
			if not tr then break end

			-- Phase 2: below target with negative velocity
			root.CFrame=tr.CFrame*CFrame.new(0,-1.5,0)
			root.Velocity=Vector3.new(-9999,-9999,-9999)
			root.RotVelocity=Vector3.new(-9999,-9999,-9999)
			RunService.Heartbeat:Wait()
		end
		if flingActive then stopFling() end
	end)
end

local knownStaff={} local function isStaff(p) if not p or p==player then return false end if knownStaff[p.UserId] then return true end if p.Team then local t=p.Team.Name:lower() if t:find("staff") or t:find("admin") or t:find("mod") then return true end end local ln=p.Name:lower() local ld=(p.DisplayName or ""):lower() return ln:find("admin") or ln:find("mod") or ln:find("staff") or ld:find("admin") or ld:find("mod") or ld:find("staff") end
local function getSelStaff() local l={} for _,p in ipairs(Players:GetPlayers()) do if p~=player and knownStaff[p.UserId] then table.insert(l,p.Name) end end table.sort(l) return l end
staffA=Players.PlayerAdded:Connect(function(p) task.wait(1) if isStaff(p) then knownStaff[p.UserId]=p.Name end end) staffR=Players.PlayerRemoving:Connect(function(p) knownStaff[p.UserId]=nil end)
for _,p in ipairs(Players:GetPlayers()) do if isStaff(p) then knownStaff[p.UserId]=p.Name end end

local function serverHop() local body=httpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100") if not body then warn("[UNIQ] HTTP failed") return end local ok,data=pcall(function() return HttpService:JSONDecode(body) end) if not ok or not data or not data.data then warn("[UNIQ] Bad list") return end local c={} for _,s in ipairs(data.data) do if s.id and s.id~=game.JobId and s.playing and s.maxPlayers and s.playing<s.maxPlayers then table.insert(c,s.id) end end if #c==0 then warn("[UNIQ] No servers") return end TeleportService:TeleportToPlaceInstance(game.PlaceId,c[math.random(1,#c)],player) end
local function rejoin() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,player) end

-- ESP
local OvE,ISelf,IDead=false,false,false local BoxE,SkelE,TrE=false,false,false
local DistE,NameE,DisplayTagsE,FillE,CornE=false,false,false,false,false
local BCol=Color3.fromRGB(175,175,175) local SCol=Color3.fromRGB(255,255,255) local TCol=Color3.fromRGB(255,255,255)
local TxtFont=Enum.Font.GothamBold local BBW,BBH=4,6.5
local SKT=1 local BoxThick=2 local TracerThick=1.5 local FillOpacity=60 local JO=1
local Boxes,Skels,Trs,DLabels,NLabels,CConns={},{},{},{},{},{}
local FontOpts={"SourceSans","SourceSansBold","SourceSansSemibold","Gotham","GothamBold","GothamSemibold","Arial","ArialBold","Fantasy","Code","SciFi","Arcade","Cartoon"}
local R15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local R6C={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
local function gR(c) return c and c:FindFirstChild("HumanoidRootPart") end local function gH(c) return c and c:FindFirstChildOfClass("Humanoid") end local function alive(c) local h=gH(c) return h and h.Health>0 end local function gC(c) if c and c:FindFirstChild("UpperTorso") then return R15 end return R6C end
local function shouldShow(p) if not OvE then return false end if not p or(ISelf and p==player) then return false end local c=p.Character if not c then return false end local r=gR(c) if not r then return false end if IDead and not alive(c) then return false end if state.ignoreFriend and (state.friends[p.Name] or state.friends[tostring(p.UserId)]) then return false end if(Camera.CFrame.Position-r.Position).Magnitude*0.28>state.visualMaxDistance then return false end return true end
local function rmBox(p) if Boxes[p] then Boxes[p]:Destroy() Boxes[p]=nil end end local function rmSkel(p) if Skels[p] then for _,l in pairs(Skels[p].lines) do l:Remove() end Skels[p]=nil end end local function rmTr(p) if Trs[p] then Trs[p]:Remove() Trs[p]=nil end end local function rmDist(p) if DLabels[p] then local g=DLabels[p].Parent DLabels[p]=nil if g then g:Destroy() end end end local function rmNm(p) if NLabels[p] then local g=NLabels[p].Parent NLabels[p]=nil if g then g:Destroy() end end end local function rmAll(p) rmBox(p) rmSkel(p) rmTr(p) rmDist(p) rmNm(p) end local function clearVis() for _,p in ipairs(Players:GetPlayers()) do rmAll(p) end end
local CN={{"HTL",true,0,0},{"VTL",false,0,0},{"HTR",true,1,0},{"VTR",false,1,0},{"HBL",true,0,1},{"VBL",false,0,1},{"HBR",true,1,1},{"VBR",false,1,1}}
local function cornerSize(h) if h then return UDim2.new(0.34,0,0,BoxThick) else return UDim2.new(0,BoxThick,0.14,0) end end
local function mkBox(p) if not BoxE then return end if not shouldShow(p) then rmBox(p) return end local r=gR(p.Character) if not r then return end rmBox(p) local b=Instance.new("BillboardGui") b.Adornee=r b.AlwaysOnTop=true b.LightInfluence=0 b.Size=UDim2.new(BBW,0,BBH,0) b.StudsOffsetWorldSpace=Vector3.new(0,-0.3,0) b.Parent=p.Character local fr=Instance.new("Frame") fr.Size=UDim2.new(1,0,1,0) fr.BorderSizePixel=0 fr.BackgroundTransparency=FillE and(1-FillOpacity/100) or 1 fr.BackgroundColor3=Color3.fromRGB(0,0,0) fr.Parent=b local s=Instance.new("UIStroke") s.Thickness=BoxThick s.Color=BCol s.Transparency=CornE and 1 or 0 s.Parent=fr for _,c in ipairs(CN) do local f=Instance.new("Frame") f.Name=c[1] f.Size=cornerSize(c[2]) f.Position=UDim2.new(c[3],0,c[4],0) f.AnchorPoint=Vector2.new(c[3],c[4]) f.BackgroundColor3=BCol f.BorderSizePixel=0 f.Visible=CornE f.Parent=fr end Boxes[p]=b end
local function mkSkel(p) if not SkelE then return end if not shouldShow(p) then rmSkel(p) return end local c=p.Character if not c then return end local cn=gC(c) rmSkel(p) Skels[p]={lines={},n=#cn} for _=1,#cn do local l=Drawing.new("Line") l.Thickness=SKT l.Color=SCol l.Transparency=1 l.Visible=false table.insert(Skels[p].lines,l) end end
local function mkTr(p) if not TrE then return end if not shouldShow(p) then rmTr(p) return end if Trs[p] then return end local l=Drawing.new("Line") l.Thickness=TracerThick l.Color=TCol l.Transparency=1 l.Visible=false Trs[p]=l end
local function mkLbl(p,store,cfg) local r=gR(p.Character) if not r or store[p] then return end local g=Instance.new("BillboardGui") g.Adornee=r g.Size=cfg.size g.AlwaysOnTop=true g.StudsOffsetWorldSpace=cfg.off g.Parent=p.Character local lb=Instance.new("TextLabel") lb.Size=UDim2.new(1,0,1,0) lb.BackgroundTransparency=1 lb.TextColor3=Color3.new(1,1,1) lb.TextStrokeTransparency=0 lb.TextSize=14 lb.Font=TxtFont lb.Text=cfg.text or "" lb.Parent=g store[p]=lb end
local function refreshPlayerVisuals(p) if not shouldShow(p) then rmAll(p) return end mkBox(p) mkSkel(p) mkTr(p) if DistE then mkLbl(p,DLabels,{size=UDim2.fromOffset(120,20),off=Vector3.new(0,-4.5,0)}) end if NameE or DisplayTagsE then local txt=DisplayTagsE and p.DisplayName or p.Name mkLbl(p,NLabels,{size=UDim2.new(140,20),off=Vector3.new(0,4.3,0),text=txt}) end end
local refresh=refreshPlayerVisuals
local function refreshAll() if not OvE then clearVis() return end for _,p in ipairs(Players:GetPlayers()) do refreshPlayerVisuals(p) end end
local function updateFill() for _,p in ipairs(Players:GetPlayers()) do local b=Boxes[p] if b then local fr=b:FindFirstChild("Frame") if fr then fr.BackgroundTransparency=FillE and(1-FillOpacity/100) or 1 local s=fr:FindFirstChildOfClass("UIStroke") if s then s.Color=BCol s.Thickness=BoxThick s.Transparency=CornE and 1 or 0 end for _,ch in ipairs(fr:GetChildren()) do if ch:IsA("Frame") then ch.BackgroundColor3=BCol ch.Visible=CornE ch.Size=cornerSize(ch.Name:sub(1,1)=="H") end end end end end end

-- ============ AUTO REATTACH (ESP respawn) ============
local function setupPlayer(plr)
	if CConns[plr] then CConns[plr]:Disconnect() CConns[plr]=nil end
	if plr.Character then refreshPlayerVisuals(plr) end
	CConns[plr]=plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        rmAll(plr)
        refreshPlayerVisuals(plr)
    end)
end

visA=Players.PlayerAdded:Connect(function(plr) task.wait(0.5) setupPlayer(plr) end)
visR=Players.PlayerRemoving:Connect(function(plr) rmAll(plr) if CConns[plr] then CConns[plr]:Disconnect() CConns[plr]=nil end end)
for _,plr in ipairs(Players:GetPlayers()) do setupPlayer(plr) end

-- also reattach own visuals after respawn
charConn=player.CharacterAdded:Connect(function()
	task.wait(0.5) cacheCol() applyWalkSpeed() applyJump()
	if state.noRagdoll then applyNoRagdoll(true) end
	flying=false resetControls() setNoClip(state.noclip)
	if state.flyEnabled then setFly(true) end
end)
if player.Character then cacheCol() setNoClip(state.noclip) if state.noRagdoll then applyNoRagdoll(true) end end

renderConn=RunService.RenderStepped:Connect(function()
	if not OvE then return end local cp=Camera.CFrame.Position local vp=Camera.ViewportSize
	for _,p in ipairs(Players:GetPlayers()) do
		local c=p.Character if not shouldShow(p) then rmAll(p) continue end
		local root=c and gR(c) local studs=root and(cp-root.Position).Magnitude or 0 local meters=studs*0.28
		if SkelE then local cn=gC(c) if not Skels[p] or Skels[p].n~=#cn then mkSkel(p) end local d=Skels[p] if d then for i,pair in ipairs(cn) do local a=c:FindFirstChild(pair[1]) local b=c:FindFirstChild(pair[2]) local l=d.lines[i] if a and b and l then local p1,v1=Camera:WorldToViewportPoint(a.Position) local p2,v2=Camera:WorldToViewportPoint(b.Position) if v1 and v2 then local x=Vector2.new(p1.X,p1.Y) local y=Vector2.new(p2.X,p2.Y) local dir=y-x if dir.Magnitude>0 then dir=dir.Unit x=x-dir*JO y=y+dir*JO end l.Visible=true l.Color=SCol l.Thickness=SKT l.From=x l.To=y else l.Visible=false end elseif l then l.Visible=false end end end else rmSkel(p) end
		if TrE then if not Trs[p] then mkTr(p) end local l=Trs[p] if root and l then local pos,on=Camera:WorldToViewportPoint(root.Position) if on then l.Visible=true l.Color=TCol l.Thickness=TracerThick l.From=Vector2.new(vp.X/2,vp.Y) l.To=Vector2.new(pos.X,pos.Y) else l.Visible=false end elseif l then l.Visible=false end else rmTr(p) end
		if DistE then if not DLabels[p] then mkLbl(p,DLabels,{size=UDim2.fromOffset(120,20),off=Vector3.new(0,-4.5,0)}) end local lb=DLabels[p] if lb and root then local g=lb.Parent if g then g.StudsOffsetWorldSpace=Vector3.new(0,-4.5-math.clamp(studs/120,0,1.2),0) end lb.Text=math.floor(meters).."m" lb.TextSize=math.clamp(18-studs/20,10,18) end else rmDist(p) end
		if NameE or DisplayTagsE then local tagText=DisplayTagsE and p.DisplayName or p.Name if not NLabels[p] then mkLbl(p,NLabels,{size=UDim2.new(140,20),off=Vector3.new(0,4.3,0),text=tagText}) end local lb=NLabels[p] if lb and root then local g=lb.Parent if g then g.StudsOffsetWorldSpace=Vector3.new(0,4.3+math.clamp(studs/120,0,1.2),0) end local isFr=state.friends[p.Name] or state.friends[tostring(p.UserId)] lb.TextColor3=isFr and Color3.fromRGB(0,166,255) or Color3.new(1,1,1) lb.TextSize=math.clamp(18-studs/20,10,18) lb.Text=tagText end else rmNm(p) end
		if BoxE then if not Boxes[p] then mkBox(p) end local box=Boxes[p] if box and root then local dB=meters>20 and math.clamp((meters-20)/95,0,0.38) or 0 local fB=meters>180 and math.clamp((meters-180)/45,0,1.2) or 0 local fL=meters>100 and math.clamp((meters-100)/90,0,0.08) or 0 box.Size=UDim2.new(BBW+dB+fB,0,BBH+dB*0.75+fB*1.1,0) local fr=box:FindFirstChild("Frame") if fr then local s=fr:FindFirstChildOfClass("UIStroke") if s then s.Color=BCol s.Thickness=BoxThick s.Transparency=CornE and 1 or 0 end local cS=0.34+dB*0.018 local vS=0.14+dB*0.01+fL local cT=math.max(1,BoxThick-(dB*0.45)) for _,ch in ipairs(fr:GetChildren()) do if ch:IsA("Frame") then if ch.Name:sub(1,1)=="H" then ch.Size=UDim2.new(cS,0,0,cT) else ch.Size=UDim2.new(0,cT,vS,0) end end end end end else rmBox(p) end
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
	["High Gravity"]=function(e) state.highGrav=e workspace.Gravity=e and 600 or 196.2 end,
	["Anti-AFK"]=function(e) state.antiAFK=e if e then if not antiAFKConn then antiAFKConn=player.Idled:Connect(function() local vu=game:GetService("VirtualUser") vu:CaptureController() vu:ClickButton2(Vector2.new(0,0)) end) end else if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn=nil end end end,
	["Auto Reattach"] = function(e)
        state.autoReattach = e
    end,
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
	["Show FOV"]=function(e) state.showFov=e end,
	["Aim Ignore Dead"]=function(e) state.aimbotIgnoreDead=e end,
}
local SH={
	["Walk Speed"]=function(v) state.walkSpeedMultiplier=tonumber(string.format("%.1f",v)) applyWalkSpeed() end,
	["Fly Speed"]=function(v) state.flySpeed=v end,
	["Jump Height"]=function(v) state.jumpHeight=v applyJump() end,
	["Max Distance"]=function(v) state.visualMaxDistance=v refreshAll() end,
	["Fill Opacity"]=function(v) FillOpacity=v updateFill() end,
	["Box Thickness"]=function(v) BoxThick=v updateFill() end,
	["Tracer Thickness"]=function(v) TracerThick=v end,
	["Skeleton Thickness"]=function(v) SKT=v end,
	["FOV Size"]=function(v) state.aimbotFov=v end,
	["Horizontal Smoothing"]=function(v) state.aimbotSmoothX=v end,
	["Vertical Smoothing"]=function(v) state.aimbotSmoothY=v end,
	["Aim Min Distance"]=function(v) state.aimMinDist=v end,
	["Aim Max Distance"]=function(v) state.aimMaxDist=v end
}
local BH={["Tp to Player"]=tpToSel,["Spectate Player"]=function() specByName(state.selectedPlayer) end,["Stop Spectating"]=stopSpec,["Fling Player"]=flingSelected,["Stop Flinging"]=stopFling}
local DS={["Select Player"]=getSelPlayers,["Select Staff"]=getSelStaff,["Text Style"]=function() return FontOpts end}
local DH={
	["Select Player"]=function(v) state.selectedPlayer=v end,
	["Select Staff"]=function(v) state.selectedStaff=v end,
	["Text Style"]=function(v) if Enum.Font[v] then TxtFont=Enum.Font[v] for _,l in pairs(DLabels) do l.Font=TxtFont end for _,l in pairs(NLabels) do l.Font=TxtFont end end end,
	["Target Part"]=function(v) state.aimbotTargetPart=v end,
	["Activation Mode"]=function(v) state.aimbotActivation=v state.aimbotToggled=false end
}

local function shutdown()
	state.walkSpeedEnabled=false state.flyEnabled=false state.jumpEnabled=false state.noJumpCooldown=false state.infiniteJump=false state.autoJump=false state.noRagdoll=false state.highGrav=false state.antiAFK=false state.noclip=false OvE=false BoxE=false SkelE=false TrE=false DistE=false NameE=false DisplayTagsE=false FillE=false state.aimbotEnabled=false
	if fovDrawing then pcall(function() fovDrawing.Visible=false; fovDrawing:Remove() end) end
	_G.UniqFovDrawing=nil
	stopSpec() stopFling() setFly(false) flying=false resetControls() applyNoRagdoll(false) workspace.Gravity=196.2
	if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn=nil end
	if aimbotConn then aimbotConn:Disconnect() aimbotConn=nil end
	for _,c in ipairs({flyConn,walkConn,noclipConn,renderConn,charConn,flyB,flyE,jumpConn,autoJumpConn,staffA,staffR,visA,visR}) do if c then pcall(function() c:Disconnect() end) end end
	local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.PlatformStand=false hum.Sit=false hum.AutoRotate=true hum:ChangeState(Enum.HumanoidStateType.GettingUp) task.wait() hum:ChangeState(Enum.HumanoidStateType.Running) end
	local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end
	updateNC() applyJump() clearVis()
	for p,c in pairs(CConns) do if c then c:Disconnect() end CConns[p]=nil end _G.UniqGen=(_G.UniqGen or 0)+1
end
_G.UniqShutdown=shutdown

-- UI THEME
local T={Window=Color3.fromRGB(19,19,19),Card=Color3.fromRGB(30,30,30),SliderBg=Color3.fromRGB(40,40,40),Rail=Color3.fromRGB(16,16,16),Track=Color3.fromRGB(48,48,48),Stroke=Color3.fromRGB(42,42,42),Accent=Color3.fromRGB(0,166,255),AccentLight=Color3.fromRGB(0,166,255),Text=Color3.fromRGB(235,235,235),ValTxt=Color3.fromRGB(200,200,200),Muted=Color3.fromRGB(140,140,140),KbGrey=Color3.fromRGB(70,70,70)}
local Fn,FM,FB=Enum.Font.Gotham,Enum.Font.GothamMedium,Enum.Font.GothamBold
local function nn(c,p) local o=Instance.new(c) for a,b in pairs(p or {}) do o[a]=b end return o end
local function corner(p,r) nn("UICorner",{CornerRadius=UDim.new(0,r or 4),Parent=p}) end
local function stroke(p,c) return nn("UIStroke",{Color=c or T.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p}) end
local function list(p,g) return nn("UIListLayout",{Padding=UDim.new(0,g or 4),SortOrder=Enum.SortOrder.LayoutOrder,Parent=p}) end
local function tw(o,t,g) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),g):Play() end
local function setIcon(img,id) img.Image="rbxassetid://"..id task.delay(2,function() if img and img.Parent and not img.IsLoaded then img.Image="rbxthumb://type=Asset&id="..id.."&w=150&h=150" end end) end
local KS={LeftShift="LShift",RightShift="RShift",LeftControl="LCtrl",RightControl="RCtrl",LeftAlt="LAlt",RightAlt="RAlt",CapsLock="Caps",Return="Enter",Escape="Esc",Space="Space",Backspace="Back",Tab="Tab",ButtonA="A",MouseButton1="M1",MouseButton2="M2",MouseButton3="M3",Unknown=""}
local function shortKey(k) if not k then return "None" end local s=(typeof(k)=="EnumItem") and k.Name or tostring(k) if KS[s] then return KS[s] end if #s>5 then return s:sub(1,5) end return s end
local function makeKbIcon(parent) local body=nn("Frame",{Size=UDim2.new(0,22,0,16),BackgroundColor3=T.KbGrey,BorderSizePixel=0,Parent=parent}) corner(body,3) for i=0,2 do nn("Frame",{Size=UDim2.new(0,4,0,3),Position=UDim2.new(0,3+i*6,0,3),BackgroundColor3=Color3.fromRGB(100,100,100),BorderSizePixel=0,Parent=body}) end nn("Frame",{Size=UDim2.new(0,14,0,3),Position=UDim2.new(0,4,0,9),BackgroundColor3=Color3.fromRGB(100,100,100),BorderSizePixel=0,Parent=body}) return body end

local oldGui=CoreGui:FindFirstChild("UNIQ") if oldGui then oldGui:Destroy() end
local Screen=nn("ScreenGui",{Name="UNIQ",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Global,Parent=CoreGui})
local FULL=UDim2.new(0,799,0,503)
local Win=nn("Frame",{Size=UDim2.new(0,799,0,0),Position=UDim2.new(0.5,-399.5,0.5,0),BackgroundColor3=T.Window,BorderSizePixel=0,ClipsDescendants=true,Visible=false,Parent=Screen})
corner(Win,8) stroke(Win,Color3.fromRGB(32,32,32))

local Rail=nn("Frame",{Size=UDim2.new(0,54,1,0),BackgroundColor3=T.Rail,BorderSizePixel=0,Parent=Win}) corner(Rail,8)
local Logo=nn("ImageLabel",{Size=UDim2.new(0,97,0,97),Position=UDim2.new(0.5,-48.5,0,4),BackgroundTransparency=1,ImageColor3=Color3.new(1,1,1),ScaleType=Enum.ScaleType.Fit,Parent=Rail}) setIcon(Logo,"115384685356525")
local RailBox=nn("Frame",{Size=UDim2.new(1,0,1,-112),Position=UDim2.new(0,0,0,102),BackgroundTransparency=1,Parent=Rail}) local rl=list(RailBox,12) rl.HorizontalAlignment=Enum.HorizontalAlignment.Center

local Header=nn("Frame",{Size=UDim2.new(1,-54,0,50),Position=UDim2.new(0,54,0,0),BackgroundTransparency=1,Parent=Win})
local Crumb=nn("TextLabel",{Size=UDim2.new(0.7,0,1,0),Position=UDim2.new(0,16,0,0),BackgroundTransparency=1,RichText=true,Font=FM,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.Text,Parent=Header})
local function setCrumb(t) Crumb.Text='<font color="#EBEBEB">UNIQ</font>   <font color="#5A5A5A">&gt;</font>   <font color="#00A6FF">'..t..'</font>' end

local MinBtn=nn("ImageButton",{Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-38,0.5,-10),BackgroundTransparency=1,ImageColor3=T.Muted,ScaleType=Enum.ScaleType.Fit,AutoButtonColor=false,Parent=Header}) setIcon(MinBtn,"83381966246889")
local Gear=nn("ImageButton",{Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-68,0.5,-10),BackgroundTransparency=1,ImageColor3=T.Muted,ScaleType=Enum.ScaleType.Fit,AutoButtonColor=false,Parent=Header}) setIcon(Gear,"118523834089694")

-- SETTINGS POPUP (moved right, stretched, bind moved left)
local POP_W=232
local settingsPop=nn("Frame",{Size=UDim2.new(0,0,0,42),Position=UDim2.new(1,-50,0.5,0),AnchorPoint=Vector2.new(1,0.5),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ClipsDescendants=true,ZIndex=100,Parent=Header})
corner(settingsPop,6) stroke(settingsPop,Color3.fromRGB(0,166,255))
nn("TextLabel",{Text="Menu Key",Font=Fn,TextSize=13,TextColor3=T.ValTxt,BackgroundTransparency=1,Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,70,0,20),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=101,Parent=settingsPop})
local menuKeyBtn=nn("TextButton",{Size=UDim2.new(0,76,0,22),Position=UDim2.new(1,-46,0.5,0),AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text=shortKey(state.menuKey),Font=FB,TextSize=11,TextColor3=T.Accent,AutoButtonColor=false,ZIndex=101,Parent=settingsPop}) corner(menuKeyBtn,4)

local popListening=false
menuKeyBtn.MouseButton1Click:Connect(function() popListening=true menuKeyBtn.Text="..." menuKeyBtn.TextColor3=Color3.new(1,1,1) end)
UIS.InputBegan:Connect(function(i,gp) if popListening and not gp then popListening=false if i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.Backspace then state.menuKey=Enum.KeyCode.RightShift elseif i.UserInputType==Enum.UserInputType.Keyboard then state.menuKey=i.KeyCode end menuKeyBtn.Text=shortKey(state.menuKey) menuKeyBtn.TextColor3=T.Accent end end)
local outsideHit=nn("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",Visible=false,ZIndex=95,Parent=Screen})
local function closeSettings() tw(settingsPop,0.18,{Size=UDim2.new(0,0,0,42)}) task.delay(0.19,function() settingsPop.Visible=false outsideHit.Visible=false end) end
outsideHit.MouseButton1Click:Connect(closeSettings)
Gear.MouseButton1Click:Connect(function() if settingsPop.Visible then closeSettings() else settingsPop.Visible=true outsideHit.Visible=true settingsPop.Size=UDim2.new(0,0,0,42) tw(settingsPop,0.22,{Size=UDim2.new(0,POP_W,0,42)}) end end)

for _,b in pairs({Gear,MinBtn}) do b.MouseEnter:Connect(function() tw(b,0.15,{ImageColor3=T.Text}) end) b.MouseLeave:Connect(function() tw(b,0.15,{ImageColor3=T.Muted}) end) end
do local dr,m0,p0 Header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true m0=i.Position p0=Win.Position i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dr=false end end) end end) UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-m0 Win.Position=UDim2.new(p0.X.Scale,p0.X.Offset+d.X,p0.Y.Scale,p0.Y.Offset+d.Y) end end) end
local minimized=false MinBtn.MouseButton1Click:Connect(function() minimized=not minimized tw(MinBtn,0.25,{Rotation=minimized and 180 or 0}) tw(Win,0.35,{Size=minimized and UDim2.new(0,300,0,58) or FULL}) end)
local Content=nn("Frame",{Size=UDim2.new(1,-66,1,-60),Position=UDim2.new(0,60,0,54),BackgroundTransparency=1,Parent=Win})
local Tabs,active={},nil
local function SwitchTab(name) for nm,t in pairs(Tabs) do local on=(nm==name) t.Page.Visible=on tw(t.Icon,0.18,{ImageColor3=on and T.Accent or T.Muted}) tw(t.Glow,0.3,{ImageTransparency=on and 0.35 or 1}) end active=name setCrumb(name) end

local function CreateTab(name,iconId,order)
	local btn=nn("TextButton",{Size=UDim2.new(0,32,0,32),BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=order,Parent=RailBox})
	local glow=nn("ImageLabel",{Size=UDim2.new(0,34,0,34),Position=UDim2.new(0.5,-17,0.5,-17),BackgroundTransparency=1,ImageColor3=T.Accent,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=1,Parent=btn}) setIcon(glow,iconId)
	local icon=nn("ImageLabel",{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0.5,-10,0.5,-10),BackgroundTransparency=1,ImageColor3=T.Muted,ScaleType=Enum.ScaleType.Fit,ZIndex=2,Parent=btn}) setIcon(icon,iconId)
	local page=nn("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false,Parent=Content})
	btn.MouseEnter:Connect(function() if active~=name then tw(icon,0.12,{ImageColor3=T.Text}) end end)
	btn.MouseLeave:Connect(function() if active~=name then tw(icon,0.12,{ImageColor3=T.Muted}) end end)
	btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
	local function makeCard(side,title)
		local card=nn("Frame",{Size=UDim2.new(0.5,-6,1,0),Position=side=="R" and UDim2.new(0.5,6,0,0) or UDim2.new(0,0,0,0),BackgroundColor3=T.Card,BorderSizePixel=0,Parent=page})
		corner(card,6)
		nn("TextLabel",{Text=title,Font=FB,TextSize=14,TextColor3=T.Text,BackgroundTransparency=1,Size=UDim2.new(1,0,0,38),Parent=card})
		local sc=nn("ScrollingFrame",{Size=UDim2.new(1,-20,1,-46),Position=UDim2.new(0,10,0,40),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=T.Accent,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=card})
		list(sc,4)
		return sc
	end
	Tabs[name]={Icon=icon,Glow=glow,Page=page,Left=function(t) return makeCard("L",t) end,Right=function(t) return makeCard("R",t) end}
	return Tabs[name]
end

local listening=nil
local function Condition(parent,text,default,fn,indent)
    local X=indent or 0 local r=nn("Frame",{Size=UDim2.new(1,-4,0,28),BackgroundTransparency=1,Parent=parent}) local st=default or false
    local box=nn("TextButton",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,4+X,0.5,-8),BackgroundColor3=st and T.Accent or T.Track,BorderSizePixel=0,Text=st and "✓" or "",TextColor3=Color3.new(1,1,1),Font=FB,TextSize=11,AutoButtonColor=false,Parent=r}) corner(box,3)
    local lbl=nn("TextLabel",{Text=text,Font=Fn,TextSize=13,TextColor3=st and T.Text or T.ValTxt,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.new(0,28+X,0,0),Size=UDim2.new(1,-80-X,1,0),Parent=r})
    local bindLbl=nn("TextLabel",{Text="",Font=FB,TextSize=10,TextColor3=T.ValTxt,TextXAlignment=Enum.TextXAlignment.Right,BackgroundTransparency=1,Position=UDim2.new(1,-58,0,0),Size=UDim2.new(0,26,1,0),Parent=r})
    local kbBtn=nn("TextButton",{Size=UDim2.new(0,22,0,16),Position=UDim2.new(1,-28,0.5,-8),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=r}) local kbBody=makeKbIcon(kbBtn) kbBody.Position=UDim2.new(0,0,0,0)
    local function apply(v) st=v tw(box,0.15,{BackgroundColor3=st and T.Accent or T.Track}) box.Text=st and "✓" or "" tw(lbl,0.15,{TextColor3=st and T.Text or T.ValTxt}) if fn then fn(st) end end
    box.MouseButton1Click:Connect(function() apply(not st) end)
    local boundKey=nil kbBtn.MouseButton1Click:Connect(function() bindLbl.Text="..." bindLbl.TextColor3=T.Accent tw(kbBody,0.15,{BackgroundColor3=T.Accent}) for _,ch in ipairs(kbBody:GetChildren()) do if ch:IsA("Frame") then tw(ch,0.15,{BackgroundColor3=Color3.fromRGB(180,230,255)}) end end listening=function(key) boundKey=key if key then bindLbl.Text=shortKey(key) bindLbl.TextColor3=T.ValTxt tw(kbBody,0.15,{BackgroundColor3=T.Accent}) for _,ch in ipairs(kbBody:GetChildren()) do if ch:IsA("Frame") then tw(ch,0.15,{BackgroundColor3=Color3.fromRGB(180,230,255)}) end end else bindLbl.Text="" tw(kbBody,0.15,{BackgroundColor3=T.KbGrey}) for _,ch in ipairs(kbBody:GetChildren()) do if ch:IsA("Frame") then tw(ch,0.15,{BackgroundColor3=Color3.fromRGB(100,100,100)}) end end end end end)
    UIS.InputBegan:Connect(function(i,gp) if boundKey and not gp and not UIS:GetFocusedTextBox() and i.KeyCode==boundKey then apply(not st) end end)
    return {Set=function(v) apply(v) end,Get=function() return st end,Row=r}
end

local function KeybindRow(parent,text,default,cb)
    local r=nn("Frame",{Size=UDim2.new(1,-4,0,28),BackgroundTransparency=1,Parent=parent})
    nn("TextLabel",{Text=text,Font=Fn,TextSize=13,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-96,1,0),Parent=r})
    local btn=nn("TextButton",{Size=UDim2.new(0,84,0,22),Position=UDim2.new(1,-88,0.5,-11),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text=shortKey(default),Font=FB,TextSize=11,TextColor3=default and T.Accent or T.ValTxt,AutoButtonColor=false,Parent=r}) corner(btn,5)
    local waiting=false local cur=default
    btn.MouseButton1Click:Connect(function() waiting=true btn.Text="..." btn.TextColor3=Color3.new(1,1,1) end)
    UIS.InputBegan:Connect(function(i,gp)
        if not waiting then return end waiting=false
        if i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.Backspace then cur=nil
        elseif i.UserInputType==Enum.UserInputType.Keyboard then cur=i.KeyCode
        elseif i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.MouseButton2 or i.UserInputType==Enum.UserInputType.MouseButton3 then cur=i.UserInputType end
        btn.Text=shortKey(cur) btn.TextColor3=cur and T.Accent or T.ValTxt
        if cb then cb(cur) end
    end)
    return {Get=function() return cur end,Row=r}
end

local function Value(parent,text,min,max,default,dec,suffix,fn) local wrap=nn("Frame",{Size=UDim2.new(1,-4,0,52),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Parent=parent}) corner(wrap,6) local val=default nn("TextLabel",{Text=text,Font=Fn,TextSize=13,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(0.6,0,0,24),Parent=wrap}) local num=nn("TextLabel",{Text=string.format("%."..dec.."f",val)..(suffix or ""),Font=Fn,TextSize=13,TextColor3=T.ValTxt,TextXAlignment=Enum.TextXAlignment.Right,BackgroundTransparency=1,Position=UDim2.new(0.4,0,0,0),Size=UDim2.new(0.6,-12,0,24),Parent=wrap}) local trackFrame=nn("Frame",{Size=UDim2.new(1,-24,0,2),Position=UDim2.new(0,12,0,34),BackgroundTransparency=1,BorderSizePixel=0,Parent=wrap}) nn("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=Color3.fromRGB(55,55,55),BorderSizePixel=0,Parent=trackFrame}) local fill=nn("Frame",{Size=UDim2.new(math.clamp((val-min)/(max-min),0,1),0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=trackFrame}) local hit=nn("TextButton",{Size=UDim2.new(1,-24,0,20),Position=UDim2.new(0,12,0,26),BackgroundTransparency=1,Text="",Parent=wrap}) local sl=false local function apply(px) local a=math.clamp((px-trackFrame.AbsolutePosition.X)/trackFrame.AbsoluteSize.X,0,1) local raw=min+(max-min)*a val=(dec==0) and math.floor(raw+0.5) or tonumber(string.format("%."..dec.."f",raw)) fill.Size=UDim2.new(a,0,1,0) num.Text=string.format("%."..dec.."f",val)..(suffix or "") if fn then fn(val) end end hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true apply(i.Position.X) end end) UIS.InputChanged:Connect(function(i) if sl and i.UserInputType==Enum.UserInputType.MouseMovement then apply(i.Position.X) end end) UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end end) return {Get=function() return val end} end

local function Dropdown(parent,text,source,default,fn)
    local wrap=nn("Frame",{Size=UDim2.new(1,-4,0,46),BackgroundTransparency=1,ClipsDescendants=true,Parent=parent})
    local current=default or "None"
    nn("TextLabel",{Text=text,Font=Fn,TextSize=13,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.new(0,0,0,0),Size=UDim2.new(0.55,0,0,30),Parent=wrap})
    local val=nn("TextLabel",{Text=current,Font=Fn,TextSize=13,TextColor3=T.ValTxt,TextXAlignment=Enum.TextXAlignment.Right,BackgroundTransparency=1,Position=UDim2.new(0.45,-16,0,0),Size=UDim2.new(0.55,0,0,30),Parent=wrap})
    local chev=nn("TextLabel",{Text="v",Font=FB,TextSize=12,TextColor3=T.Muted,BackgroundTransparency=1,Position=UDim2.new(1,-14,0,0),Size=UDim2.new(0,12,0,30),Parent=wrap})
    nn("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,0,30),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=wrap})
    local optsFrame=nn("Frame",{Position=UDim2.new(0,0,0,40),Size=UDim2.new(1,0,0,0),BackgroundColor3=T.SliderBg,BorderSizePixel=0,ClipsDescendants=true,Parent=wrap}) corner(optsFrame,6) local ol=list(optsFrame,2) ol.HorizontalAlignment=Enum.HorizontalAlignment.Center nn("UIPadding",{PaddingTop=UDim.new(0,3),Parent=optsFrame})
    local rowHit=nn("TextButton",{Size=UDim2.new(1,0,0,40),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=2,Parent=wrap})
    local open=false
    local function build() for _,c in pairs(optsFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end local opts=(type(source)=="function") and source() or source if not opts or #opts==0 then opts={"(none)"} end for _,opt in ipairs(opts) do local isFr=state.friends[opt] local o=nn("TextButton",{Size=UDim2.new(1,-6,0,24),BackgroundColor3=T.Accent,BackgroundTransparency=(opt==current) and 0.8 or 1,AutoButtonColor=false,Text=opt,Font=Fn,TextSize=12,TextColor3=isFr and Color3.fromRGB(0,166,255) or T.Text,Parent=optsFrame}) corner(o,5) o.MouseEnter:Connect(function() tw(o,0.1,{BackgroundTransparency=0.7}) end) o.MouseLeave:Connect(function() tw(o,0.1,{BackgroundTransparency=(o.Text==current) and 0.8 or 1}) end) o.MouseButton1Click:Connect(function() if opt=="(none)" then return end current=opt val.Text=opt if fn then fn(opt) end open=false tw(chev,0.15,{Rotation=0}) tw(optsFrame,0.2,{Size=UDim2.new(1,0,0,0)}) tw(wrap,0.2,{Size=UDim2.new(1,-4,0,46)}) end) end return #opts end
    rowHit.MouseButton1Click:Connect(function()
        open=not open
        if open then local n=build() local h=n*26+6 tw(chev,0.15,{Rotation=180}) tw(optsFrame,0.2,{Size=UDim2.new(1,0,0,h)}) tw(wrap,0.2,{Size=UDim2.new(1,-4,0,46+h)})
        else tw(chev,0.15,{Rotation=0}) tw(optsFrame,0.2,{Size=UDim2.new(1,0,0,0)}) tw(wrap,0.2,{Size=UDim2.new(1,-4,0,46)}) end
    end)
    return {Get=function() return current end}
end

local function Button(parent,text,fn) local b=nn("TextButton",{Size=UDim2.new(1,-4,0,32),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Text=text,Font=FM,TextSize=13,TextColor3=T.Text,AutoButtonColor=false,Parent=parent}) corner(b,6) stroke(b,Color3.fromRGB(38,38,38)) b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundColor3=Color3.fromRGB(50,50,50)}) end) b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=T.SliderBg}) end) b.MouseButton1Click:Connect(function() tw(b,0.08,{BackgroundColor3=Color3.fromRGB(24,60,90)}) task.delay(0.15,function() tw(b,0.15,{BackgroundColor3=T.SliderBg}) end) if fn then fn() end end) return b end
UIS.InputBegan:Connect(function(i) if listening then task.wait() local cb=listening listening=nil if i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.Backspace then cb(nil) return end if i.UserInputType==Enum.UserInputType.Keyboard then cb(i.KeyCode) end end end)
UIS.InputBegan:Connect(function(i,gp) if gp then return end if state.aimbotActivation=="Toggle" and state.aimbotKey then local k=state.aimbotKey local m=false if typeof(k)=="EnumItem" then if k.EnumType==Enum.KeyCode and i.KeyCode==k then m=true elseif k.EnumType==Enum.UserInputType and i.UserInputType==k then m=true end end if m then state.aimbotToggled=not state.aimbotToggled end end end)

-- PREVIEW
local previewPos=UDim2.new(1,-330,0,60)
local previewGui,previewActive=nil,false
local function closePreview() if previewGui then local wf=previewGui:FindFirstChild("Frame") if wf then previewPos=wf.Position end previewGui:Destroy() previewGui=nil end previewActive=false end
local function TogglePreview()
    if previewActive then closePreview() return end
    previewActive=true
    local old=CoreGui:FindFirstChild("UniqPreview") if old then old:Destroy() end
    local gui=nn("ScreenGui",{Name="UniqPreview",ResetOnSpawn=false,Parent=CoreGui}) previewGui=gui
    local W,H=247,391
    local win=nn("Frame",{Name="Frame",Size=UDim2.new(0,W,0,H),Position=previewPos,BackgroundColor3=Color3.fromRGB(12,12,12),BorderSizePixel=0,ClipsDescendants=true,Parent=gui}) corner(win,8) stroke(win)
    win:GetPropertyChangedSignal("Position"):Connect(function() if previewActive then previewPos=win.Position end end)
    local top=nn("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Parent=win}) corner(top,8) nn("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BackgroundColor3=T.SliderBg,BorderSizePixel=0,Parent=top}) nn("TextLabel",{Text="ESP Preview",Font=FB,TextSize=12,TextColor3=T.Text,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Parent=top})
    do local dr,m0,p0 top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true m0=i.Position p0=win.Position i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dr=false end end) end end) UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-m0 win.Position=UDim2.new(p0.X.Scale,p0.X.Offset+d.X,p0.Y.Scale,p0.Y.Offset+d.Y) end end) end
    local cv=nn("Frame",{Size=UDim2.new(1,0,1,-28),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,ClipsDescendants=true,Parent=win})
    local ox=W/2
    local headW,headH,headR=41,50,14
    local torsoW,torsoH=76,82
    local armW,armH=34,82
    local legW,legH=36,88
    local gap=2 local headTop=68 local torsoY=headTop+headH+gap local legY=torsoY+torsoH+gap local bottom=legY+legH
    local bodyCol=Color3.fromRGB(216,216,219) local headCol=Color3.fromRGB(230,230,232) local edge=Color3.fromRGB(125,125,130)
    local function part(x,y,w,h,col,r) local f=nn("Frame",{Size=UDim2.fromOffset(w,h),Position=UDim2.fromOffset(x,y),BackgroundColor3=col,BorderSizePixel=0,Parent=cv}) corner(f,r or 3) nn("UIStroke",{Color=edge,Thickness=1,Parent=f}) return f end
    part(ox-headW/2,headTop,headW,headH,headCol,headR) part(ox-torsoW/2,torsoY,torsoW,torsoH,bodyCol,4) part(ox-torsoW/2-armW-gap,torsoY,armW,armH,bodyCol,3) part(ox+torsoW/2+gap,torsoY,armW,armH,bodyCol,3) part(ox-legW-1,legY,legW,legH,bodyCol,3) part(ox+1,legY,legW,legH,bodyCol,3)
    local J={headC={ox,headTop+headH/2},neck={ox,torsoY+5},shL={ox-torsoW/2,torsoY+10},shR={ox+torsoW/2,torsoY+10},handL={ox-torsoW/2-armW/2-gap,torsoY+armH-7},handR={ox+torsoW/2+armW/2+gap,torsoY+armH-7},hip={ox,torsoY+torsoH},footL={ox-legW/2,bottom},footR={ox+legW/2,bottom}}
    local skelLines={}
    local function sLine(a,b) local x1,y1=a[1],a[2] local x2,y2=b[1],b[2] local mx,my=(x1+x2)/2,(y1+y2)/2 local dx,dy=x2-x1,y2-y1 local len=math.sqrt(dx*dx+dy*dy) local ang=math.deg(math.atan2(dy,dx)) local l=nn("Frame",{Size=UDim2.fromOffset(len,2),Position=UDim2.fromOffset(mx,my),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=SCol,BorderSizePixel=0,Rotation=ang,ZIndex=3,Parent=cv}) table.insert(skelLines,{f=l,len=len}) end
    sLine(J.headC,J.neck) sLine(J.neck,J.shL) sLine(J.neck,J.shR) sLine(J.shL,J.handL) sLine(J.shR,J.handR) sLine(J.neck,J.hip) sLine(J.hip,J.footL) sLine(J.hip,J.footR)
    local pad=8 local boxTop=headTop-pad local boxBot=bottom+pad local boxLeft=ox-torsoW/2-armW-gap-pad local boxRight=ox+torsoW/2+armW+gap+pad
    local espBox=nn("Frame",{Size=UDim2.fromOffset(boxRight-boxLeft,boxBot-boxTop),Position=UDim2.fromOffset(boxLeft,boxTop),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2,Parent=cv})
    local espStroke=nn("UIStroke",{Thickness=2,Color=BCol,Parent=espBox})
    local cFrames={}
    local function mkC(h,ax,ay) local f=nn("Frame",{BackgroundColor3=BCol,BorderSizePixel=0,Visible=false,AnchorPoint=Vector2.new(ax,ay),Position=UDim2.new(ax,0,ay,0),ZIndex=4,Parent=espBox}) if h then f.Size=UDim2.new(0.3,0,0,2) else f.Size=UDim2.new(0,2,0.12,0) end table.insert(cFrames,{f=f,h=h}) end
    mkC(true,0,0) mkC(false,0,0) mkC(true,1,0) mkC(false,1,0) mkC(true,0,1) mkC(false,0,1) mkC(true,1,1) mkC(false,1,1)
    local tracer=nn("Frame",{Size=UDim2.fromOffset(2,H-28-boxBot-24),Position=UDim2.fromOffset(ox-1,boxBot+6),BackgroundColor3=TCol,BorderSizePixel=0,Parent=cv})
    local nameL=nn("TextLabel",{Size=UDim2.fromOffset(140,16),Position=UDim2.fromOffset(ox-70,boxTop-36),BackgroundTransparency=1,Text="PlayerName",Font=TxtFont,TextSize=13,TextColor3=Color3.new(1,1,1),TextStrokeTransparency=0,ZIndex=4,Parent=cv})
    local distL=nn("TextLabel",{Size=UDim2.fromOffset(80,16),Position=UDim2.fromOffset(ox-40,H-52),BackgroundTransparency=1,Text="50m",Font=TxtFont,TextSize=12,TextColor3=Color3.new(1,1,1),TextStrokeTransparency=0,ZIndex=4,Parent=cv})
    local function upd()
        espBox.Visible=BoxE espStroke.Thickness=BoxThick espStroke.Color=BCol espBox.BackgroundTransparency=FillE and(1-FillOpacity/100) or 1
        if CornE then espStroke.Transparency=1 else espStroke.Transparency=0 end
        for _,c in ipairs(cFrames) do c.f.Visible=CornE c.f.BackgroundColor3=BCol if c.h then c.f.Size=UDim2.new(0.3,0,0,math.max(1,BoxThick)) else c.f.Size=UDim2.new(0,math.max(1,BoxThick),0.12,0) end end
        tracer.Visible=TrE tracer.Size=UDim2.fromOffset(math.max(1,TracerThick),H-28-boxBot-24) tracer.BackgroundColor3=TCol
        for _,l in ipairs(skelLines) do l.f.Visible=SkelE l.f.BackgroundColor3=SCol l.f.Size=UDim2.fromOffset(l.len,math.max(1,SKT)) end
        nameL.Visible=NameE or DisplayTagsE nameL.Text=DisplayTagsE and "DisplayName" or "PlayerName" nameL.Font=TxtFont
        distL.Visible=DistE distL.Font=TxtFont
    end
    upd()
    local conn=RunService.Heartbeat:Connect(function() if not previewActive or not gui.Parent then conn:Disconnect() return end upd() end)
end

-- BUILD TABS
local Combat  = CreateTab("Combat",  "113941213386286", 1)
local Player  = CreateTab("Player",  "136841993281886", 2)
local Visuals = CreateTab("Visuals", "72545313930928",  3)
local Online  = CreateTab("Online",  "115957001084004", 4)
local Misc    = CreateTab("Misc",    "82749417460131",  5)

local cL=Combat.Left("Aimbot")
Condition(cL,"Aimbot",false,function(v) TH["Aimbot"](v) end)
KeybindRow(cL,"Aim Key",nil,function(k) state.aimbotKey=k end)
Dropdown(cL,"Activation Mode",{"Hold","Toggle"},"Hold",function(v) DH["Activation Mode"](v) end)
Condition(cL,"Show FOV",false,function(v) TH["Show FOV"](v) end)
Condition(cL,"Ignore Dead",false,function(v) TH["Aim Ignore Dead"](v) end)
Condition(cL,"Ignore Friend",false,function(v) TH["Ignore Friend"](v) end)
local cR=Combat.Right("Customization")
Dropdown(cR,"Aim Method",{"Camera","MouseMoveRel","Silent"},"Camera",function(v) state.aimMethod=v end)
Dropdown(cR,"Target Part",{"Head","Neck","Torso","Closest"},"Head",function(v) DH["Target Part"](v) end)
Value(cR,"FOV Size",1,360,120,0,"",function(v) SH["FOV Size"](v) end)
Value(cR,"Horizontal Smoothing",1,100,10,0,"",function(v) SH["Horizontal Smoothing"](v) end)
Value(cR,"Vertical Smoothing",1,100,10,0,"",function(v) SH["Vertical Smoothing"](v) end)
Value(cR,"Min Distance",1,100,1,0,"",function(v) SH["Aim Min Distance"](v) end)
Value(cR,"Max Distance",1,500,500,0,"",function(v) SH["Aim Max Distance"](v) end)

local pL=Player.Left("Conditions")
Condition(pL,"Speed",false,function(v) TH["Toggle"](v,"Speed") end) Condition(pL,"Fly",false,function(v) TH["Toggle"](v,"Fly") end) Condition(pL,"Super Jump",false,function(v) TH["Toggle"](v,"Super Jump") end) Condition(pL,"Infinite Jump",false,function(v) TH["Infinite Jump"](v) end) Condition(pL,"Auto Jump",false,function(v) TH["Auto Jump"](v) end) Condition(pL,"No Jump Cooldown",false,function(v) TH["No Jump Cooldown"](v) end) Condition(pL,"No Ragdoll",false,function(v) TH["No Ragdoll"](v) end) Condition(pL,"High Gravity",false,function(v) TH["High Gravity"](v) end) Condition(pL,"NoClip",false,function(v) TH["NoClip"](v) end)
local pR=Player.Right("Customization") Value(pR,"Walk Speed",1,50,1.0,1,"",function(v) SH["Walk Speed"](v) end) Value(pR,"Fly Speed",50,500,300,0,"",function(v) SH["Fly Speed"](v) end) Value(pR,"Jump Height",7.2,100,7.2,1,"",function(v) SH["Jump Height"](v) end)

local vL=Visuals.Left("Conditions") Condition(vL,"Enabled",false,function(v) TH["Enabled"](v) end)
local fillCond,cornerCond
local boxesCond=Condition(vL,"Boxes",false,function(v) TH["Boxes"](v) if fillCond then fillCond.Row.Visible=v if v then fillCond.Row.Size=UDim2.new(1,-4,0,0) tw(fillCond.Row,0.25,{Size=UDim2.new(1,-4,0,28)}) end end if cornerCond then cornerCond.Row.Visible=v if v then cornerCond.Row.Size=UDim2.new(1,-4,0,0) tw(cornerCond.Row,0.25,{Size=UDim2.new(1,-4,0,28)}) end end end)
fillCond=Condition(vL,"Filled Boxes",false,function(v) TH["Filled Boxes"](v) end,16) cornerCond=Condition(vL,"Corner Boxes",false,function(v) TH["Corner Boxes"](v) end,16) fillCond.Row.Visible=false cornerCond.Row.Visible=false
Condition(vL,"Skeleton",false,function(v) TH["Skeleton"](v) end) Condition(vL,"Tracers",false,function(v) TH["Tracers"](v) end) Condition(vL,"Distance",false,function(v) TH["Distance"](v) end)
local nameCond,displayCond
nameCond=Condition(vL,"Nametags",false,function(v) if v and displayCond then displayCond.Set(false) end TH["Nametags"](v) end)
displayCond=Condition(vL,"Display Tags",false,function(v) if v and nameCond then nameCond.Set(false) end TH["Display Tags"](v) end)
Condition(vL,"Ignore Dead",false,function(v) TH["Ignore Dead"](v) end) Condition(vL,"Ignore Self",false,function(v) TH["Ignore Self"](v) end)
Condition(vL,"Ignore Friend",false,function(v) TH["Ignore Friend"](v) end)
local vR=Visuals.Right("Customization")
Value(vR,"Max Distance",50,2000,500,0,"m",function(v) SH["Max Distance"](v) end)
Value(vR,"Fill Opacity",0,100,60,0,"%",function(v) SH["Fill Opacity"](v) end)
Value(vR,"Box Thickness",1,5,2,1,"",function(v) SH["Box Thickness"](v) end)
Value(vR,"Tracer Thickness",1,5,1.5,1,"",function(v) SH["Tracer Thickness"](v) end)
Value(vR,"Skeleton Thickness",1,5,1,1,"",function(v) SH["Skeleton Thickness"](v) end)
Dropdown(vR,"Text Style",function() return DS["Text Style"]() end,"GothamBold",function(v) DH["Text Style"](v) end)
Button(vR,"Toggle Preview",TogglePreview)

local oL=Online.Left("Players")
Dropdown(oL,"Select Player",function() return DS["Select Player"]() end,"None",function(v)
	DH["Select Player"](v)
	if state.friendBtn then state.friendBtn.Text=state.friends[v] and "Remove Friend" or "Add Friend" state.friendBtn.TextColor3=state.friends[v] and Color3.fromRGB(0,166,255) or T.Text end
end)
Dropdown(oL,"Select Staff",function() return DS["Select Staff"]() end,"None",function(v) DH["Select Staff"](v) end)
local oR=Online.Right("Actions")
Button(oR,"Tp to Player",function() BH["Tp to Player"]() end)
Button(oR,"Spectate Player",function() BH["Spectate Player"]() end)
Button(oR,"Stop Spectating",function() BH["Stop Spectating"]() end)
Button(oR,"Fling Player",function() BH["Fling Player"]() end)
Button(oR,"Stop Flinging",function() BH["Stop Flinging"]() end)
local friendBtn=Button(oR,"Add Friend",function()
	local pName=state.selectedPlayer
	if pName and pName~="None" then
		if state.friends[pName] then state.friends[pName]=nil else state.friends[pName]=true end
		state.friendBtn.Text=state.friends[pName] and "Remove Friend" or "Add Friend"
		state.friendBtn.TextColor3=state.friends[pName] and Color3.fromRGB(0,166,255) or T.Text
		refreshAll()
	end
end)
state.friendBtn=friendBtn

local mL=Misc.Left("Menu")
Condition(mL,"Anti-AFK",false,function(v) TH["Anti-AFK"](v) end)
Condition(mL,"Auto Reattach",true,function(v) TH["Auto Reattach"](v) end)
Button(mL,"Unload Menu",function() closePreview() pcall(shutdown) _G.UniqShutdown=nil Screen:Destroy() end)
local mR=Misc.Right("Utilities")
Button(mR,"Server Hop",serverHop) Button(mR,"Rejoin Server",rejoin) Button(mR,"Copy Server ID",function() if setclipboard then setclipboard(game.JobId) end end)
Button(mR,"Reset Character",function() local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.Health=0 end end)
Button(mR,"Toggle Fullbright",function() local L=game:GetService("Lighting") if L.Ambient==Color3.new(1,1,1) then L.Ambient=Color3.fromRGB(127,127,127) L.Brightness=2 L.FogEnd=100000 else L.Ambient=Color3.new(1,1,1) L.OutdoorAmbient=Color3.new(1,1,1) L.Brightness=5 L.FogEnd=1e9 for _,e in ipairs(L:GetChildren()) do if e:IsA("Atmosphere") or e:IsA("BloomEffect") or e:IsA("ColorCorrectionEffect") then e.Enabled=false end end end end)
Button(mR,"Dex Explorer",function() task.spawn(function() local src=httpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua") if src then loadstring(src)() else warn("[UNIQ] Dex failed") end end) end)

-- INTRO
local introFinished=false
do local ac=T.Accent local cb=Color3.fromRGB(20,140,255) local pb=Color3.fromRGB(18,64,120) local pt=Color3.fromRGB(215,240,255) local txt=Color3.fromRGB(240,240,240) local soft=Color3.fromRGB(166,166,176) local ob=Lighting:FindFirstChild("UniqIntroBlur") if ob then ob:Destroy() end local blur=nn("BlurEffect",{Name="UniqIntroBlur",Size=0,Parent=Lighting}) local ov=nn("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=50,Parent=Screen}) local title=nn("TextLabel",{Size=UDim2.new(0,520,0,58),Position=UDim2.new(0.5,0,0.45,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Text="UNIQ",Font=Enum.Font.GothamBlack,TextSize=42,TextColor3=txt,TextTransparency=1,ZIndex=51,Parent=ov}) local sub=nn("TextLabel",{Size=UDim2.new(0,230,0,22),Position=UDim2.new(0.5,18,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Text="Successfully Injected",Font=FM,TextSize=13,TextColor3=txt,TextTransparency=1,ZIndex=51,Parent=ov}) local chk=nn("TextLabel",{Size=UDim2.fromOffset(16,16),Position=UDim2.new(0.5,-62,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=cb,BackgroundTransparency=1,BorderSizePixel=0,Text="✓",Font=FB,TextSize=15,TextColor3=Color3.new(1,1,1),TextTransparency=1,ZIndex=51,Parent=ov}) corner(chk,8) local line=nn("Frame",{Size=UDim2.new(0,250,0,2),Position=UDim2.new(0.5,0,0.479,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=ac,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=51,Parent=ov}) corner(line,1) nn("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.18,0.55),NumberSequenceKeypoint.new(0.5,0.08),NumberSequenceKeypoint.new(0.82,0.55),NumberSequenceKeypoint.new(1,1)}),Parent=line}) local stat=nn("Frame",{Size=UDim2.new(0,285,0,30),Position=UDim2.new(0.5,17,0.545,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,ZIndex=50,Parent=ov}) local pr=nn("TextLabel",{Size=UDim2.fromOffset(46,28),Position=UDim2.fromOffset(17,1),BackgroundTransparency=1,Text="Press",Font=Fn,TextSize=13,TextColor3=soft,TextTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=51,Parent=stat}) local pill=nn("TextLabel",{Size=UDim2.fromOffset(56,20),Position=UDim2.fromOffset(60,5),BackgroundColor3=pb,BackgroundTransparency=1,BorderSizePixel=0,Text="RSHIFT",Font=FB,TextSize=10,TextColor3=pt,TextTransparency=1,ZIndex=51,Parent=stat}) corner(pill,3) local ps=stroke(pill,ac) ps.Transparency=1 local stx=nn("TextLabel",{Size=UDim2.new(0,150,1,0),Position=UDim2.fromOffset(129,0),BackgroundTransparency=1,Text="to open the menu",Font=FM,TextSize=13,TextColor3=soft,TextTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=51,Parent=stat}) local IN=TweenInfo.new(1.0,Enum.EasingStyle.Quad,Enum.EasingDirection.Out) local OUT=TweenInfo.new(0.21,Enum.EasingStyle.Quad,Enum.EasingDirection.In) tw(blur,0.64,{Size=18}) TweenService:Create(title,IN,{TextTransparency=0}):Play() TweenService:Create(sub,IN,{TextTransparency=0}):Play() TweenService:Create(chk,IN,{TextTransparency=0,BackgroundTransparency=0}):Play() TweenService:Create(line,IN,{BackgroundTransparency=0.08}):Play() TweenService:Create(pr,IN,{TextTransparency=0}):Play() TweenService:Create(pill,IN,{TextTransparency=0,BackgroundTransparency=0.08}):Play() TweenService:Create(ps,IN,{Transparency=0.35}):Play() TweenService:Create(stx,IN,{TextTransparency=0}):Play() task.delay(3.40,function() TweenService:Create(blur,OUT,{Size=0}):Play() TweenService:Create(title,OUT,{TextTransparency=1}):Play() TweenService:Create(sub,OUT,{TextTransparency=1}):Play() TweenService:Create(chk,OUT,{TextTransparency=1,BackgroundTransparency=1}):Play() TweenService:Create(line,OUT,{BackgroundTransparency=1}):Play() TweenService:Create(pr,OUT,{TextTransparency=1}):Play() TweenService:Create(pill,OUT,{TextTransparency=1,BackgroundTransparency=1}):Play() TweenService:Create(ps,OUT,{Transparency=1}):Play() TweenService:Create(stx,OUT,{TextTransparency=1}):Play() end) task.delay(3.59,function() if ov.Parent then ov:Destroy() end if blur.Parent then blur:Destroy() end introFinished=true end) end

local lastPos=UDim2.new(0.5,-399.5,0.5,-251.5) local menuOpen=false local menuAnimating=false
UIS.InputBegan:Connect(function(i,gp)
	if gp or menuAnimating then return end
	if introFinished and i.KeyCode==state.menuKey then
		menuAnimating=true menuOpen=not menuOpen
		local halfH=FULL.Y.Offset/2 local centerY=lastPos.Y.Offset+halfH
		if menuOpen then
			Win.Visible=true Win.Size=UDim2.new(FULL.X.Scale,FULL.X.Offset,0,0) Win.Position=UDim2.new(lastPos.X.Scale,lastPos.X.Offset,lastPos.Y.Scale,centerY)
			tw(Win,0.35,{Size=FULL,Position=lastPos})
			task.delay(0.36,function() menuAnimating=false end)
		else
			lastPos=Win.Position
			local halfH2=FULL.Y.Offset/2 local centerY2=lastPos.Y.Offset+halfH2
			closePreview()
			tw(Win,0.25,{Size=UDim2.new(FULL.X.Scale,FULL.X.Offset,0,0),Position=UDim2.new(lastPos.X.Scale,lastPos.X.Offset,lastPos.Y.Scale,centerY2)})
			task.delay(0.26,function() if not menuOpen then Win.Visible=false end menuAnimating=false end)
		end
	end
end)

ppcall(function()
	local queue = queue_on_teleport or (syn and syn.queue_on_teleport)
	if not queue then return end

	player.OnTeleport:Connect(function(ts)
		if ts == Enum.TeleportState.Started and state.autoReattach then
			queue([[
				task.wait(2)
				loadstring(game:HttpGet("https://raw.githubusercontent.com/Verticakos/UNIQ/refs/heads/main/UNIQ.lua"))()
			]])
		end
	end)
end)

SwitchTab("Player") print("[UNIQ] V25 loaded.")
