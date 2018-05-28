if myHero.charName ~= "Riven" then return end
require "DamageLib"

keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
local HKITEM = {[ITEM_1] = HK_ITEM_1,[ITEM_2] = HK_ITEM_2,[ITEM_3] = HK_ITEM_3,[ITEM_4] = HK_ITEM_4,[ITEM_5] = HK_ITEM_5,[ITEM_6] = HK_ITEM_6,[ITEM_7] = HK_ITEM_7}

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local barHeight = 8
local barWidth = 103
local barXOffset = 0
local barYOffset = 0
local EZdelaying = true
local _tickFrequency = .2
local NextSpellCast = Game.Timer()
local LocalGameMinionCount 	=  Game.MinionCount;
local LocalGameHeroCount 			= Game.HeroCount;
local LocalGameHero 				= Game.Hero;
local LocalGameMinionCount 			= Game.MinionCount;
local LocalGameMinion 				= Game.Minion;
local LocalGameTurretCount 			= Game.TurretCount;
local Qstacks = 0


-- I AM RIVEN DUDE MADE BY THEDUDE / FORUM-NAME: THE1DUDE
--				* CREDITS *
--	Toscin - for qaa solution
--


function SetMovement(bool)
	if _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
	
	if bool then
		castSpell.state = 0
	end
end

class "Riven"
local Scriptname,Version,Author,LVersion = "Iam Riven Dude","v2.0","The1Dude","8.5"

function Riven:__init()

	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker found"		
	else
		orbwalkername = "Orbwalker not found"
	end
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
	
end

function CurrentTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	end
end

function GetMode()
    if _G.SDK then
        if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
            return "Combo"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
            return "Harass"	
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then return "Clear"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
            return "LastHit"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
            return "Flee"
        end
    end
end

function Riven:LoadSpells()
	Q = { range = 275, delay = 0.25, speed = 1800, width = 30, IsLine = true}
	W = { range = myHero:GetSpellData(_W).range, delay = 0.267, speed = 999999, IsLine = false }
	E = { range = 300, delay = 0.25, speed = 1450, width = 0, IsLine = true }
	R = { range = 950, delay = 0.25, speed = 1600, width = myHero:GetSpellData(_R).width, radius = 50, Angle= 50, IsLine = false, collision=false }
end

function Riven:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "Iam Riven Dude", name = Scriptname})
	self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
	self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Use Q", value = true})
	self.Menu.ComboMode:MenuElement({id = "AccuracyQ", name = "Q Accuracy", value = 2, min = 1, max = 6, step = 1 })
	self.Menu.ComboMode:MenuElement({id = "UseW", name = "Use W", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseE", name = "Use E", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseR2", name = "Use R2", value = true})
	self.Menu.ComboMode:MenuElement({id = "AccuracyR2", name = "R2 Accuracy", value = 2, min = 1, max = 6, step = 1 })
	self.Menu.ComboMode:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	self.Menu.ComboMode:MenuElement({id = "fleeActive", name = "Flee key", key = string.byte(" ")})
	self.Menu.ComboMode:MenuElement({id = "UseHYDRA", name = "Use hydra", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseGHOST", name = "Use ghostblade", value = true})
	self.Menu.ComboMode:MenuElement({id = "DrawDamage", name = "Draw damage on HPbar", value = true})
		
	self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
	self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Use Q", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseW", name = "Use W", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseE", name = "Use E", value = true})
	self.Menu.HarassMode:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	
	self.Menu:MenuElement({id = "KSMenu", name = "Killsteal", type = MENU})
	self.Menu.KSMenu:MenuElement({id = "UseQ", name = "Use Q", value = true})
	self.Menu.KSMenu:MenuElement({id = "UseW", name = "Use W", value = true})
	self.Menu.KSMenu:MenuElement({id = "UseR2", name = "Use R2", value = true})
	self.Menu.KSMenu:MenuElement({id = "AccuracyR2", name = "R2 Accuracy", value = 2, min = 1, max = 6, step = 1 })

	self.Menu:MenuElement({id = "ClearMode", name = "Clear", type = MENU})
	self.Menu.ClearMode:MenuElement({id = "UseQ", name = "Use Q", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseW", name = "Use W", value = true})
	self.Menu.ClearMode:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})

	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some WTF problems with wrong directions", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 100, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	
	--self.Menu:MenuElement({id = "Evade", name = "Q & E - EVADE", type = MENU})
	--self.Menu.Evade:MenuElement({id = "EvadeActive", name = "ON / OFF", value = true})
	--self.Menu.Evade:MenuElement({id = "EvadeAuto", name = "Danger Level (Auto)", value = 4, min = 1, max = 6, step = 1 })
	--self.Menu.Evade:MenuElement({id = "EvadeCombo", name = "Danger Level (Combo)", value = 1, min = 1, max = 6, step = 1 })
	
	--_G.Alpha.ObjectManager:OnSpellCast(function(spell) OnSpellCast(spell) end)
	
end 

function Riven:Tick()
    if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true then return end
	SetMovement(true)
	
	if self.Menu.ComboMode.fleeActive:Value() then
		self:Flee()
	end
	
	--if self.Menu.Evade.EvadeActive:Value() then
	--	self:Evade()
	--end
	
	if self.Menu.KSMenu.UseQ:Value() or self.Menu.KSMenu.UseW:Value() or self.Menu.KSMenu.UseR2:Value() and self:EnemyInRange(1000) then
		self:Killsteal()
	end
	
	if self.Menu.ComboMode.comboActive:Value() and self:EnemyInRange(1000) then
		self:Combo()
	end
	
	if self.Menu.HarassMode.harassActive:Value() and self:EnemyInRange(500) then
		self:Harass()
	end
	
	if self.Menu.ClearMode.clearActive:Value() then
		self:Clear()
	end
end

-- Combo / Harass / Clear / Flee / Killsteal / Evade

function Riven:Combo()
	if not GetMode() == "Combo" then return end
	local target = CurrentTarget(950)
	local Etarget = CurrentTarget(400)
	local Wtarget = CurrentTarget(260)
	
	self:QSpellLoop()
	

	
	
	if target and target.valid and target.isTargetable then
		local THP = target.health/(target.maxHealth)*100
		
		
		if self.Menu.ComboMode.UseW:Value() and self:CanCast(_W) and Wtarget and Wtarget.valid and Wtarget.isTargetable then
			local HPD = myHero.health/(myHero.maxHealth)*100
			if (HPD <= 15) then
				local castPos = Wtarget:GetPrediction(W.Speed, W.Delay)
				_G.Control.CastSpell(HK_W, castPos)
			end
		end
		
		if self.Menu.ComboMode.UseE:Value() and self:CanCast(_E) and Etarget and Etarget.valid and Etarget.isTargetable then
			local HPD = myHero.health/(myHero.maxHealth)*100
			if (HPD <= 15) then
				local castPos = Etarget:GetPrediction(E.Speed, E.Delay)
				_G.Control.CastSpell(HK_E, castPos)
			end
		end
		
		if self:CanCast(_W) and self.Menu.ComboMode.UseW:Value() and Wtarget and Wtarget.valid and EnemyCount(myHero.pos, 260) >= 2 then
			local castPos = Wtarget:GetPrediction(W.Speed, W.Delay)
			_G.Control.CastSpell(HK_W, castPos)
		
		elseif self:EnemyInRange(500) and not self:EnemyInRange(300) then
			
			if self:CanCast(_E) and self:CanCast(_Q) and self.Menu.ComboMode.UseQ:Value() and self.Menu.ComboMode.UseE:Value() then
				local castPos = target:GetPrediction(3250, 0.60)
				_G.Control.CastSpell(HK_E, castPos)
				DelayAction(function() _G.Control.CastSpell(HK_Q, castPos) end, 0.10)
			end
			
			if self.Menu.ComboMode.UseHYDRA:Value() and self:EnemyInRange(174) then
				if myHero.attackData.state == STATE_WINDDOWN then
					UseHydra()
				end
			end
			

			
		elseif self.Menu.ComboMode.UseQ:Value() and self:CanCast(_Q) then
			
			self:CastQ()
			
			if self.Menu.ComboMode.UseHYDRA:Value() and self:EnemyInRange(174) then
				if myHero.attackData.state == STATE_WINDDOWN then
					UseHydra()
				end
			end
			
		end
		
		if Qstacks >= 1 and self:CanCast(_W) and self.Menu.ComboMode.UseW:Value() and Wtarget and Wtarget.valid and Wtarget.isTargetable then
			
			local castPos = Wtarget:GetPrediction(W.Speed, W.Delay)
			_G.Control.CastSpell(HK_W, castPos)
			
		end
		
		if Qstacks >= 1 and self:CanCast(_W) and self.Menu.ComboMode.UseW:Value() and Wtarget and Wtarget.valid and Wtarget.isTargetable then
			
			local castPos = Wtarget:GetPrediction(W.Speed, W.Delay)
			_G.Control.CastSpell(HK_W, castPos)
			
		end
		
		if self.Menu.ComboMode.UseHYDRA:Value() and _G.Alpha.Geometry:IsInRange(myHero.pos, target.pos, 174) and target.isTargetable then
			UseHydra()
		end
		
		if self.Menu.ComboMode.UseR2:Value() and EnemyCount(myHero.pos, 950) >= 2 and myHero:GetSpellData(3).name == "RivenIzunaBlade" and self:CanCast(_R) and target.isTargetable and target.valid and target.health > 0 then
			local castPos, accuracy = _G.Alpha.Geometry:GetCastPosition(myHero, target, 950, 0.25, 1600, 50, false, false)
			if accuracy >= self.Menu.ComboMode.AccuracyR2:Value() and _G.Alpha.Geometry:IsInRange(myHero.pos, target.pos, 950) then
				DisableOrb()
				_G.Control.CastSpell(HK_R, castPos)
				DelayAction(function() EnableOrb() end, 0.10)
			end
		end
		
	end
end

function Riven:Harass()
	if not GetMode() == "Harass" then return end
	local target = CurrentTarget(500)
	
	if target and target.valid and target.isTargetable then
		
		if self:CanCast(_E) and self:CanCast(_Q) and EnemyCount(myHero.pos, 1000) <= 2 then
		
			local castPos = target:GetPrediction(3250, 0.60)
			_G.Control.CastSpell(HK_E, castPos)
			DelayAction(function() self:CastQ() end, 0.10)
		
			
		end
		
		
		if not self:CanCast(_E) then
			if self:CanCast(_Q) and myHero.attackData.state == STATE_WINDDOWN then
				local castPos = target:GetPrediction(Q.Speed, Q.Delay)
				self:CastQ()
			end
		
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 250  and self:CanCast(_W) then
			DelayAction(function() Control.CastSpell(HK_W) end, 0.25)
		end
		
		
	end
	

end

function Riven:Flee()
	
	if GetMode() == "Flee" then  
		
		if self:CanCast(_E) then
		
			_G.Control.CastSpell(HK_E, cursorPos)
			if self:CanCast(_Q) then
				DelayAction(function() _G.Control.CastSpell(HK_Q, cursorPos) end, 0.1)			
			end
			
		elseif self:CanCast(_Q) then
		
			_G.Control.CastSpell(HK_Q, cursorPos)
		
		end
		
	end
end

function Riven:Killsteal()
	if GetMode() == "Flee" then return end
	if myHero.dead then return end
	
for i, hero in pairs(self:GetEnemyHeroes()) do
	local QDamage = (self:CanCast(_Q) and getdmg("Q", hero, myHero) or 0)
	local WDamage = (self:CanCast(_W) and getdmg("W", hero, myHero) or 0)
	local RDamage = (self:CanCast(_R) and getdmg("R", hero, myHero) or 0)
	local AADamage = myHero.totalDamage
	local AARange = myHero.range
	
	if _G.Alpha.Geometry:IsInRange(myHero.pos, hero.pos, 90) then
		local target = CurrentTarget(AARange)
		if target and target.valid and target.isTargetable and AADamage >= target.health then
			_G.Control.Attack(target)
		end
	
	elseif self.Menu.KSMenu.UseQ:Value() and self:CanCast(_Q) and QDamage > 0 then

		local target = CurrentTarget(275)
		if target and target.valid and target.isTargetable and QDamage >= target.health and myHero.attackData.state == STATE_WINDDOWN then
			local castPos = target:GetPrediction(Q.Speed, Q.Delay)
			_G.Control.CastSpell(HK_Q, castPos)
		end
	
	elseif self.Menu.KSMenu.UseW:Value() and self:CanCast(_W) and WDamage > 0 then
	
		local target = CurrentTarget(250)
		if target and target.valid and target.isTargetable and WDamage >= target.health and myHero.attackData.state == STATE_WINDDOWN then
			local castPos = target:GetPrediction(W.Speed, W.Delay)
			_G.Control.CastSpell(HK_W, castPos)
		end
	
	elseif self.Menu.KSMenu.UseR2:Value() and myHero:GetSpellData(3).name == "RivenIzunaBlade" and self:CanCast(_R) and RDamage > 0 then
	
		local target = CurrentTarget(950)
		if target and target.valid and target.isTargetable and RDamage >= target.health and _G.Alpha.Geometry:IsInRange(myHero.pos, target.pos, 950) then
			local castPos, accuracy = _G.Alpha.Geometry:GetCastPosition(myHero, target, 950, 0.25, 1600, 50, false, false)
			if accuracy >= self.Menu.KSMenu.AccuracyR2:Value() then
			DisableOrb()
			_G.Control.CastSpell(HK_R, castPos)
			DelayAction(function() EnableOrb() end, 0.10)
			end
		end
	
	end
end
end

function Riven:Clear()
	if GetMode() == "Clear" then  
	
	for i = 1, Game.MinionCount() do
	
		local minion = Game.Minion(i)
		if minion and minion.team == 300 or minion.team ~= myHero.team then
	
			if self:CanCast(_Q) and self.Menu.ClearMode.UseQ:Value() and minion then 
				if self.Menu.ClearMode.UseQ:Value() and ValidTarget(minion, 275) then
					if myHero.pos:DistanceTo(minion.pos) > 270 and myHero.attackData.state == STATE_WINDDOWN then
						local castPos = minion:GetPrediction(Q.Range, Q.Delay)
						self:CastSpell(HK_Q, castPos)
						if minion then
						Control.Attack(minion)
						end
					end
				end
			end

			if self:CanCast(_W) and self.Menu.ClearMode.UseW:Value()and minion then 
				if self.Menu.ClearMode.UseW:Value() and ValidTarget(minion, 250) then
					if myHero.pos:DistanceTo(minion.pos) < 250 and myHero.attackData.state == STATE_WINDDOWN then
						Control.CastSpell(HK_W)
						if minion then
						Control.Attack(minion)
						end
					end
				end
			end
			
			if self.Menu.ComboMode.UseHYDRA:Value() and minion then
				if myHero.pos:DistanceTo(minion.pos) < 170 then
					UseHydraminion()
				end
			end
			
		end
	end
	end
end

function Riven:Evade()
	
	--OnSpellCast()

end
	


--FUNCTIONS

function Riven:QSpellLoop()
			local time, spellQ = NextSpellCast, myHero:GetSpellData(_Q)        
			local timeSinceCast = time - spellQ.castTime + spellQ.cd

			for i=1, 3 do
				if timeSinceCast < 0.1 + (i==3 and 0.25 or 0) and spellQ.ammo == i and Qstacks ~= i then 
					--PrintChat("Q"..i.." Casted") 
									
					Qstacks = i  
					
				end
			end
end	

function EnemyCount(origin, range)
	local count = 0
	for i  = 1,LocalGameHeroCount(i) do
		local enemy = LocalGameHero(i)
		if enemy and enemy.type == "AIHeroClient" and enemy.isEnemy and enemy.valid and enemy.health > 0 and enemy.isTargetable and _G.Alpha.Geometry:IsInRange(origin, enemy.pos, range) then
			count = count + 1
		end			
	end
	return count
end

function OnSpellCast(spell)
	if spell.isEnemy and self:IsReady(_E) then
		local hitDetails = _G.Alpha.DamageManager:GetSpellHitDetails(spell,myHero)
		if hitDetails.Hit and hitDetails.Path then
			if hitDetails.Danger >= self.Menu.Evade.EvadeAuto:Value() or (GetMode() == "Combo" and hitDetails.Danger >= self.Menu.Evade.EvadeCombo:Value()) then	
				local dashPos = myHero.pos + hitDetails.Path * R.Range				
				CastSpell(HK_E, dashPos)
			end				
		end
	end
end

function Riven:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end

function Riven:EnemyInRange(range)
	local count = 0
	for i, target in ipairs(self:GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range then 
			count = count + 1
		end
	end
	return count
end

local EZdelaying = true
local _tickFrequency = .2

function Riven:IsDelaying()
	if NextSpellCast > Game.Timer() then return true end
	if EZdelaying then
		NextSpellCast = Game.Timer() + _tickFrequency
	end
	return false
end

function Riven:IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Riven:CanCast(spellSlot)
	return self:IsReady(spellSlot)
end

function DisableOrb()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetMovement(false)
		_G.SDK.Orbwalker:SetAttack(false)
	end
end

function EnableOrb()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	end
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	DelayAction(EnableMovement,0.1)
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

function Riven:Draw()
    local textPos = myHero.pos:To2D()
    if self:CanCast(_Q) then Draw.Circle(myHero.pos, 275, 2,  Draw.Color(255, 255, 000, 255)) end
    if self:CanCast(_R) then Draw.Circle(myHero.pos, 950, 2,  Draw.Color(255, 255, 000, 255)) end
	if self.Menu.ComboMode.DrawDamage:Value() then
		for i, hero in pairs(self:GetEnemyHeroes()) do
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				local QDamage = (self:CanCast(_Q) and getdmg("Q",hero,myHero) or 0)
				local WDamage = (self:CanCast(_W) and getdmg("W",hero,myHero) or 0)
				local EDamage = (self:CanCast(_E) and getdmg("E",hero,myHero) or 0)
				local RDamage = (self:CanCast(_R) and getdmg("R",hero,myHero) or 0)
				local damage = QDamage + WDamage + EDamage + RDamage
				if damage > hero.health then
					Draw.Text("killable", 24, hero.pos2D.x, hero.pos2D.y,Draw.Color(0xFF00FF00))
					
				else
					local percentHealthAfterDamage = math.max(0, hero.health - damage) / hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, Draw.Color(0xFF00FF00))
				end
			end
		end	
	end
end

function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		
		return nil
end
	
function UseHydra()
		local HTarget = CurrentTarget(125)
	if HTarget then 
		local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077)
		if hydraitem then
			Control.CastSpell(HKITEM[hydraitem],HTarget.pos)
            Control.Attack(HTarget)
		end
	end
end

function UseHydraminion()
    for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
        if minion and minion.team == 300 or minion.team ~= myHero.team then 
			local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077)
			if hydraitem then
				Control.CastSpell(HKITEM[hydraitem], minion.pos)
                Control.Attack(minion)
			end
		end
    end
end

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function ValidTarget(target, range)
	range = range and range or math.huge
	return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

function Riven:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end



LastCancel = Game.Timer()
function Riven:CastQ(target)
    local qrange = 420 
    local qtarg = CurrentTarget(qrange)
	local QRONGE = 275
	self:QSpellLoop()
	
    if qtarg and qtarg.valid then
		
		if Qstacks >= 2 then
			QRONGE = 420
		else
			QRONGE = 275
		end
		
        if qtarg.dead or qtarg.isImmune then return end
        if myHero.pos:DistanceTo(qtarg.pos) < 420 and self:HasBuff(myHero, "rivenwindslashready") then    --myHero.range
            if self:CanCast(_Q) and myHero.attackData.state == STATE_WINDDOWN then
				
                local castPos, accuracy = _G.Alpha.Geometry:GetCastPosition(myHero, qtarg, QRONGE, 0.25, 1450, 30, false, true)
				if accuracy >= self.Menu.ComboMode.AccuracyQ:Value() then
					DisableOrb()
					_G.Control.CastSpell(HK_Q,qtarg)
					_G.Control.Attack(qtarg)
					DelayAction(function() EnableOrb() end, 0.3)
					if Game.Timer() - LastCancel > 0.13 then
						LastCancel = Game.Timer()
						DelayAction(function()
						local Vec = Vector(myHero.pos):Normalized() * - (myHero.boundingRadius*1.1)
						_G.Control.Move(Vec)
						end, (0.25 + Game.Latency()/1000))
					end
				end
			end
        else
        	if myHero.pos:DistanceTo(qtarg.pos) < QRONGE and not self:HasBuff(myHero, "rivenwindslashready") then    --Q without buff less range wont chase with q but aa more reliable
            	if self:CanCast(_Q) and myHero.attackData.state == STATE_WINDDOWN then
                	local castPos, accuracy = _G.Alpha.Geometry:GetCastPosition(myHero, qtarg, QRONGE, 0.25, 1450, 30, false, false)
					if accuracy >= self.Menu.ComboMode.AccuracyQ:Value() then
						DisableOrb()
						_G.Control.CastSpell(HK_Q,qtarg)
						_G.Control.Attack(qtarg)
						DelayAction(function() EnableOrb() end, 0.3)
						if Game.Timer() - LastCancel > 0.13 then
							LastCancel = Game.Timer()
							DelayAction(function()
							local Vec = Vector(myHero.pos):Normalized() * - (myHero.boundingRadius*1.1)
							_G.Control.Move(Vec)
							end, (0.25 + Game.Latency()/1000))
						end
					end
            	end
        	end
        end
    end
end

function Riven:CastSpell(spell,pos)
	local customcast = self.Menu.CustomSpellCast:Value()
	if not customcast then
		_G.Control.CastSpell(spell, pos)
		return
	else
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				SetMovement(false)
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end

function OnLoad()
	Riven()
end
