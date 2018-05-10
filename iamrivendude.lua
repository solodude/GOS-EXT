if myHero.charName ~= "Riven" then return end
keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}



-- CREDITS HPred / Ics Orbwalker  / Auto script auto : Sikaka / for paste ;)

local minicounter
local orb_
local Qstacks
local LastQ
local AARange = 125
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local NextSpellCast = Game.Timer()
local barHeight = 8
local barWidth = 103
local barXOffset = 0
local barYOffset = 0
local LocalGameMinionCount 	=  Game.MinionCount;
local LocalGameHeroCount 			= Game.HeroCount;
local LocalGameHero 				= Game.Hero;
local LocalGameMinionCount 			= Game.MinionCount;
local LocalGameMinion 				= Game.Minion;
local LocalGameTurretCount 			= Game.TurretCount;
local LocalGameTurret 


function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		SDK.Orbwalker:SetMovement(bool)
		SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
	if bool then
		castSpell.state = 0
	end
end

class "Riven"
local Scriptname,Version,Author,LVersion = "IAM Riven DUDE"," v1.0"," the1dude"," 8.8"
require "DamageLib"

function init_value()
	orb_ = true
	minicounter = 0
	Qstacks = 0
end

function get_orb()
	return orb_
end

function true_orb()
	orb_ = true
	return orb_
end

function false_orb()
	orb_ = false
	return orb_
end

function get_counter()
	return minicounter
end

function plus_counter()
	minicounter = minicounter + 1
	return minicounter
end

function reset_counter()
	minicounter = 0
	return minicounter
end

function Riven:__init()
	init_value()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"
	elseif _G.EOW then
		orbwalkername = "EOW"	
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
	else
		orbwalkername = "Orbwalker not found"
		
	end
	PrintChat(Scriptname.." "..Version.." - Loaded orbwalker:"..orbwalkername .. (TPred and " TPred" or ""))
	PrintChat("Hey Duderino, its Loaded ! ")
end

--[[Spells]]
function Riven:LoadSpells()
	Q = {Range = 275, 
		Widht = 0,
		Delay = 0.3,
		Speed = 1800}
	
	W = {Range = 260, 
		Widht = 0,
		Delay = 0.25,
		Speed = 1500,}
	
	E = {Range = 300, 
		Widht = 0,
		Delay = 0.25,
		Speed = 1450}
	
	R = {Range = 950, 
		Widht = myHero:GetSpellData(3).width,
		Delay = 0.25,
		Speed = myHero:GetSpellData(3).speed}
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

function Riven:IsInRange(p1, p2, range)
	if not p1 or not p2 then
		return false
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) < range * range 
end

function Riven:CurrentPctLife(entity)
	local pctLife =  entity.health/entity.maxHealth  * 100
	return pctLife
end

function Riven:IsFarming()
	if _G.SDK and _G.SDK.Orbwalker then		
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
			return true
		end
	end
	return false
end

function Riven:IsHarass()
	if _G.SDK and _G.SDK.Orbwalker then		
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return true
		end
	end
	return false
end

function Riven:IsCombo()
	if _G.SDK and _G.SDK.Orbwalker then		
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return true
		end
	end
	return false
end

function Riven:IsFlee()
	if _G.SDK and _G.SDK.Orbwalker then		
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			return true
		end
	end
	return false
end

function Riven:IsEvading()
    if ExtLibEvade and ExtLibEvade.Evading then return true end
	return false
end

function Riven:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "iam riven dude", name = Scriptname})
	
	--[[Combo]]
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	self.Menu.Combo:MenuElement({id = "rCombo", name = "R Combo", key = string.byte("T")})
	self.Menu.Combo:MenuElement({id = "fleemode", name = "Flee mode", key = string.byte("A")})
	self.Menu.Combo:MenuElement({id = "comboDelay", name = "Delay / Verify cast", value = true})
	self.Menu.Combo:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu.Combo:MenuElement({id = "farmUseQ", name = "Farm - Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "farmUseW", name = "Farm - Use W", value = true})
	self.Menu.Combo:MenuElement({id = "farmactive", name = "Farm key", key = string.byte("V")})
	self.Menu.Combo:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu.Combo:MenuElement({id = "comboUseR", name = "Use R if killable", value = true})
	self.Menu.Combo:MenuElement({id = "secondR", name = "Use R2 if killable", value = true})
	for i, hero in pairs(self:GetEnemyHeroes()) do
		self.Menu.Combo:MenuElement({id = "RU"..hero.charName, name = "UseR in rCombo only on: "..hero.charName, value = true})
	end
	
	

	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "harassUseW", name = "Use W", value = true})
	self.Menu.Harass:MenuElement({id = "harassUseE", name = "Use E", value = true})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	--KS
	self.Menu:MenuElement({type = MENU, id = "KSMenu", name = "KS Settings"})
	self.Menu.KSMenu:MenuElement({id = "KillStealQ", name = "Use Q", value = true})
	self.Menu.KSMenu:MenuElement({id = "KillStealW", name = "Use W", value = true})
	self.Menu.KSMenu:MenuElement({id = "KillStealR", name = "Use R2", value = true})
	self.Menu.KSMenu:MenuElement({id = "KillStealI", name = "Use Ignite | !! NEED TO BE 2 SPELL !!", value = true})
	self.Menu.KSMenu:MenuElement({id = "Ignite", name = "IGNITE IF KILLABLE KEY", key = string.byte("G")})
	--DRAW
	self.Menu:MenuElement({type = MENU, id = "DrawMenu", name = "Draw Settings"})
	self.Menu.DrawMenu:MenuElement({id = "TextOffset", name = "Z offset for text ", value = 0, min = -100, max = 100})
	self.Menu.DrawMenu:MenuElement({id = "TextSize", name = "Font size ", value = 30, min = 2, max = 64})
	self.Menu.DrawMenu:MenuElement({id = "DrawOnEnemy", name = "Killable text on enemy", value = true})
	self.Menu.DrawMenu:MenuElement({id = "DrawOnHPBar", name = "Damage on hpbar", value = true})
	self.Menu.DrawMenu:MenuElement({id = "DrawColor", name = "Color for drawing", color = Draw.Color(0xBF3F3FFF)})
	--DRAW
	self.Menu.DrawMenu:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "QRangeC", name = "Q Range color", color = Draw.Color(0xBF8F8FFF)})
	self.Menu.DrawMenu:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "WRangeC", name = "W Range color", color = Draw.Color(0xBFBF3FFF)})
	self.Menu.DrawMenu:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "ERangeC", name = "E Range color", color = Draw.Color(0xBFBF3FFF)})
	self.Menu.DrawMenu:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "RRangeC", name = "R Range color", color = Draw.Color(0xBFBF3FFF)})
	
	--ETC
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 60, min = 0, max = 600, step = 30, identifier = ""})
	self.Menu:MenuElement({id = "qaamode", name = "QAA - MODES", value = 5, min = 1, max = 7, })
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. "" .. (TPred and " TPred" or "")})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function CurrentModes()
	local canmove, canattack
	if _G.SDK then -- ic orbwalker
		canmove = _G.SDK.Orbwalker:CanMove()
		canattack = _G.SDK.Orbwalker:CanAttack()
	elseif _G.EOW then -- eternal orbwalker
		canmove = _G.EOW:CanMove() 
		canattack = _G.EOW:CanAttack()
	else -- default orbwalker
		canmove = _G.GOS:CanMove()
		canattack = _G.GOS:CanAttack()
	end
	return canmove, canattack
end

--DELAY
	local EZdelaying = true
	local _tickFrequency = .2

	function Riven:IsDelaying()
		if NextSpellCast > Game.Timer() then return true end
		if EZdelaying then
			NextSpellCast = Game.Timer() + _tickFrequency
		end
		return false
	end
	
--DELAY


function Riven:Tick()
	if myHero.dead then return end
	
	--QAA MODE
	local qaaState = self.Menu.qaamode:Value()
	--QAA MODE
	local KillStealIgnite = self.Menu.KSMenu.Ignite:Value()
	local fleemode = self.Menu.Combo.fleemode:Value()
	local combomodeactive = self.Menu.Combo.comboActive:Value()
	local farmactive = self.Menu.Combo.farmactive:Value()
	local harassactive = self.Menu.Harass.harassActive:Value()
	local KillSteal = self.Menu.KSMenu.KillStealW:Value() or self.Menu.KSMenu.KillStealR:Value() or self.Menu.KSMenu.KillStealQ:Value() 
		
		if fleemode and  _G.SDK.ORBWALKER_MODE_FLEE then
			if self:IsAttacking() and self:IsDelaying() and self:IsEvading() then return end
			if NextSpellCast > Game.Timer() then return end
			
			self:CastFlee()
			
		elseif KillSteal then
			local KSDamage = 0
			local KSTarget = nil
			if NextSpellCast > Game.Timer() then return end
			if self:IsAttacking() and self:IsDelaying() then return end
			--AUTO IGNITE
			
			--if self.Menu.KSMenu.KillStealI:Value() then
				--for _, enemy in pairs(self:GetEnemyHeroes()) do
					--if enemy.isTargetable and self:CanCast(HK_SUMMONER_2) and _G.GOS:CanAttack(myHero) and enemy.alive and enemy.valid then
						--if 20 * myHero.levelData.lvl + 50 > enemy.health + enemy.hpRegen * 3 then
						--	_G.Control.CastSpell(HK_SUMMONER_2, enemy)
							
						--end
					--end
				--end
			--end	
			
			--Q
			if self:CanCast(_Q) and self.Menu.KSMenu.KillStealQ:Value() then
				if KSDamage == 0 then
					KSTarget = (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AD"))
					if KSTarget then 
						KSDamage = KSDamage + getdmg("Q",KSTarget,myHero)		
						if KSDamage > KSTarget.health then 
							Control.CastSpell(HK_Q,KSTarget)
							self:CastAA()
							
						end
					end
				else
					KSDamage = KSDamage + getdmg("Q",KSTarget,myHero)
					if KSDamage > KSTarget.health then 
						Control.CastSpell(HK_Q,KSTarget)
						self:CastAA()
						
					end
				end
			--W
			elseif self:CanCast(_W) and self.Menu.KSMenu.KillStealW:Value() then
				if KSDamage == 0 then
					KSTarget = (_G.SDK and _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(W.Range,"AD"))
					if KSTarget then 
						KSDamage = KSDamage + getdmg("W",KSTarget,myHero)		
						if KSDamage > KSTarget.health then 
							_G.Control.CastSpell(HK_W,KSTarget)
						end
					end
				else
					KSDamage = KSDamage + getdmg("W",KSTarget,myHero)
					if KSDamage > KSTarget.health then 
						_G.Control.CastSpell(HK_W,KSTarget)
					end
				end
			--R2
			elseif myHero:GetSpellData(3).name == "RivenIzunaBlade" and self.Menu.KSMenu.KillStealR:Value() and self:CanCast(_R) then
			if KSDamage == 0 then
				KSTarget = (_G.SDK and _G.SDK.TargetSelector:GetTarget(25000, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(25000,"AD"))
				if KSTarget then 
					KSDamage = KSDamage + getdmg("R",KSTarget,myHero)		
					if KSDamage > KSTarget.health then 
						local castPos
						castPos = KSTarget:GetPrediction(1450, 0.25)
						self:CastSpell(HK_R,castPos)
						return
					end
				end
			else
				KSDamage = KSDamage + getdmg("R",KSTarget,myHero)
				if KSDamage > KSTarget.health then 
					castPos = KSTarget:GetPrediction(R.Speed,R.Delay)
					self:CastSpell(HK_R,castPos)
					return
				end
			end
		end
		
	--COMBO
	if combomodeactive and self:IsCombo() then

		local Qcd = myHero:GetSpellData(0).currentCd
		
		--CHECKS
		if self:IsAttacking() and self:IsDelaying() then return end
		if NextSpellCast > Game.Timer()then return end	
		
		--SPECIAL EVENTS
		if myHero:GetSpellData(3).name == "RivenIzunaBlade" and Qcd <= 0.3 then
			local HPD = myHero.health/(myHero.maxHealth)*100
			if (HPD <= 10) then
				Target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(1450, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(1450,"AD"))
					if Target then 	
						local HPE = Target.health/(Target.maxHealth)*100
						if HPE <= 40 and self:CanCast(_Q) then 
							local castPos
							castPos = KSTarget:GetPrediction(1450, 0.25)
							self:CastSpell(HK_R,castPos)
						end
					end
			end
		end
		
		if self:IsImmobileTarget(myHero) and myHero.alive and self:IsReady(_W) then
			self:CastW()
		end
	
		--ENGAGE
		--W
		if self.Menu.Combo.comboUseW and self:CanCast(_W) then
			local HPD = myHero.health/(myHero.maxHealth)*100
			if (HPD <= 31) then
				self:CastW()
				self:CastAA()
				if NextSpellCast > Game.Timer() then return end	
			end
		end
		--E
		if self.Menu.Combo.comboUseE and self:CanCast(_E) then
			local HPD = myHero.health/(myHero.maxHealth)*100
			if (HPD >= 20 and HPD <= 30) then
				_G.Control.CastSpell(HK_E,mousePos.x,mousePos.y,mousePos.z)
			else
				local enemy = (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AD"))
				if enemy and enemy.isEnemy then
					local pctLife =  enemy.health/enemy.maxHealth  * 100
					if pctLife <= 15 and HPD >= 10 then
						castPos = enemy:GetPrediction(E.Speed,E.Delay)
						_G.Control.CastSpell(HK_E, castPos)
					end
				end
			end
		end	
		
		--NORMALCOMBO
		
		
		
		
		if qaaState == 1 then
			local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AD"))
			self:QSpellLoop()
		if target and target.type == "AIHeroClient" and target.valid then
			if Qstacks == 1 then
                
				if self:IsInRange(myHero.pos , target.pos, 124) == false then
					self:CastQ()
				elseif self:get_counter() == 0 then
				self:CastAA()
				self:plus_counter()
				end
                				
            elseif Qstacks == 2 then
				
				if self:IsInRange(myHero.pos , target.pos, 124) == false then
					self:CastQ()
				elseif self:get_counter() == 1 then
				self:CastAA()
				self:plus_counter()
				end
				
            elseif Qstacks == 3 then
				
				if self:IsInRange(myHero.pos , target.pos, 124) == false then
					self:CastQ()
				elseif self:get_counter() == 2 then
				self:CastAA()
				self:plus_counter()
				end
			end
		end
			if not self:IsAttacking() then
			self:CastQ()
			elseif self:get_counter() == 2 then
			self:reset_counter()
			end
			
		elseif qaaState == 2 then
			
			if self.Menu.Combo.comboUseQ:Value() and self:CanCast(_Q) then
				if get_orb() == true then
					self:CastQ()
					false_orb()
					if NextSpellCast > Game.Timer() and self:IsDelaying() and self:IsAttacking() then  
						return 
					end
				end
			end
		
			if get_orb() == false then
				if NextSpellCast > Game.Timer() and self:IsDelaying() and self:IsAttacking() then  
					return 
				end
				self:CastAA()
				true_orb()
			end
			
		
			if get_orb() == false then
			PrintChat "get_obs - ERROR - wrong value"
			end
		
		elseif qaaState == 3 then
			
			-- value 60-90
			if self.Menu.Combo.comboUseQ:Value() and self:CanCast(_Q) then
				
				--AA
				if get_orb() == true then
					self:CastAA()
					false_orb()
				end
				--Q
				if get_orb() == false then
				self:CastQ()
				
				if self:IsDelaying() and self:IsAttacking() then self:CastQ() true_orb() return end
				if NextSpellCast > Game.Timer() then self:CastQ() true_orb() return end
				true_orb()
				end
			
			end	
			
		elseif qaaState == 4 then
			-- 0 / 1 / 2 / q modes 3
			-- 0.25 q delay 
			local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AD"))
			if target and target.type == "AIHeroClient" and self:CanCast(_Q) and target.valid then
				self:CastQ()
			
				self:QSpellLoop()
			
				if self:ResetQ() <= 3 then
					if self:IsInRange(myHero.pos , target.pos, 124) == false then
						self:CastQ()
						Qstacks = Qstacks - 1
						self:QSpellLoop()
						
					elseif target.valid then
					 
						self:CastAA()
						Qstacks = Qstacks - 1
					end
				end
				
			end
		
		elseif qaaState == 5 then
			
			if self.Menu.Combo.comboUseQ:Value() and self:CanCast(_Q) then
				
				--AA
				if get_orb() == true then
					self:CastAADelayed()
					false_orb()
				end
				--Q
				if get_orb() == false then
				self:CastQ()
				
				if self:IsDelaying() and self:IsAttacking() then self:CastQ() true_orb() return end
				if NextSpellCast > Game.Timer() then self:CastQ() true_orb() return end
				true_orb()
				end
			
			end	
		
		end
		
		--W
		
		
			if self.Menu.Combo.comboUseW:Value() and self:CanCast(_W) then
				self:CastW()
				if not self:CanCast(_W) then
					if _G.GOS:CanAttack(myHero)then
						self:CastAA()
						if NextSpellCast > Game.Timer() then return end
					end
				end
			end
		
		--MULTITARGETS
		
	
	
	--HARASS & FARM
	elseif harassactive and self:IsHarass() then 
		if self:IsEvading() then return end
		if self.Menu.Harass.harassUseQ:Value() and self:CanCast(_Q) then
			self:CastQ()
		elseif self.Menu.Harass.harassUseW:Value() and self:CanCast(_W) then
			self:CastW()
		elseif self.Menu.Harass.harassUseE:Value() and self:CanCast(_E) then
			
		end
	elseif farmactive and self:IsFarming() then
		
		if self:IsEvading() then return end
		if farmactive then
		for i = 1, LocalGameMinionCount() do
			local t = LocalGameMinion(i)
			
			if t and self:IsInRange(myHero.pos, t.pos, Q.Range ) and self:CanTarget(t) and self:GetQDamage(t) >= t.health and self:CanCast(_Q) then
					castPos = t:GetPrediction(Q.Speed, Q.Delay)
					_G.Control.CastSpell(HK_Q, castPos)
				end
			end
		end
		end
		
		
        if self.Menu.Combo.farmUseQ:Value() and self:CanCast(_Q) then
		
		
			
		end
		
		elseif self.Menu.Combo.farmUseW:Value() and self:CanCast(_W) then
		
		
		end

	end

	--FUNCTIONS
	
-- TASKS #################
function Riven:IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end
	
function Riven:QSpellLoop()
			local time, spellQ = NextSpellCast, myHero:GetSpellData(_Q)        
			local timeSinceCast = time - spellQ.castTime + spellQ.cd

			for i=1, 3 do
				if timeSinceCast < 0.1 + (i==3 and 0.25 or 0) and spellQ.ammo == i and Qstacks ~= i then 
					PrintChat("Q"..i.." Casted") 
					--PrintChat("T - "..time.." --")					
					Qstacks = i  
					--LastQ = time    
					
					
					if Qstacks >= 4 then
					PrintChat " Overflow ERROR "
					end
					return
				end
			end
end	

function Riven:ResetQ(i)
	if i == nil then
	i = 0
	end
	return i
end

function EnableMovement()
	SetMovement(true)
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	DelayAction(EnableMovement,0.1)
end

function LeftClick(pos)
	_G.Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	_G.Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.75,{pos})
end

function RightMoves(pos)
	_G.Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
	_G.Control.mouse_event(MOUSEEVENTF_RIGHTUP)
	DelayAction(ReturnCursor,0.75,{pos})
end

function Riven:FarmQ()
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i);
		if minion and self:CanTarget(minion) and self:IsInRange(myHero.pos, minion.pos, Q.Range) then
		
			local predictedHealth = minion.health
			if _G.SDK and _G.SDK.HealthPrediction then
				predictedHealth = _G.SDK.HealthPrediction:GetPrediction(minion, Q.Delay)
			end
			local qDamage = self:GetQDamage(minion)
			local predictedDamage = minion.health - predictedHealth
			
			if predictedHealth > 0 and (predictedDamage < 25 or predictedHealth > 25) and qDamage > predictedHealth + 5 then
				local aimPosition = self:PredictUnitPosition(minion, Q.Delay)
				local valid = true
				for _, q in pairs(_cachedQs) do
					if self:IsInRange(q.data.pos, aimPosition, Q.Width) then
						valid = false
					end
				end
				if valid then					
					self:CastSpell(HK_Q, aimPosition)
				end
			end
		end
	end
end 

function UseBotrk()
		local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(300, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(300,"AD"))
		if target then 
			local botrkitem = GetInventorySlotItem(3153) or GetInventorySlotItem(3144)
			if botrkitem then
				local keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
				Control.CastSpell(keybindings[botrkitem],target.pos)
			end
		end
end 

function Riven:CanTarget(target, allowInvisible)
	return target.isEnemy and target.alive and target.health > 0  and (allowInvisible or target.visible) and target.isTargetable
end

--CALCULATION #############################

function Riven:CalculateIncomingDamage()
	_incomingDamage = {}
	local currentTime = Game.Timer()
	for _, missile in pairs(_cachedMissiles) do
		if missile then 
			local dist = self:GetDistance(missile.data.pos, missile.target.pos)			
			if missile.name == "" or currentTime >= missile.timeout or dist < missile.target.boundingRadius then
				_cachedMissiles[_] = nil
			else
				if not _incomingDamage[missile.target.networkID] then
					_incomingDamage[missile.target.networkID] = missile.damage
				else
					_incomingDamage[missile.target.networkID] = _incomingDamage[missile.target.networkID] + missile.damage
				end
			end
		end
	end	
end

function Riven:GetIncomingDamage(target)
	local damage = 0
	if _incomingDamage[target.networkID] then
		damage = _incomingDamage[target.networkID]
	end
	return damage
end

function GetDistanceSqr(p1, p2)
	assert(p1, "GetDistance: invalid argument: cannot calculate distance to "..type(p1))
	return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function GetDistance(p1, p2)
	return math.sqrt(GetDistanceSqr(p1, p2))
end


function Riven:GetQDamage(target)
    local level = myHero:GetSpellData(_Q).level
    local damage = 48 + 4 * myHero.levelData.lvl + 0.1 * myHero.ap + level * 0.60 * myHero.ap or 0
	damage = self:CalculatePhysicalDamage(target, damage)		
	return damage
end

function Riven:CountAlliesInRange(point, range)
  if type(point) ~= "userdata" then error("{CountAlliesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
  local range = range == nil and math.huge or range 
  if type(range) ~= "number" then error("{CountAlliesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
  local n = 0
  for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if unit.isAlly and not unit.isMe and IsValidTarget(unit, range, false, point) then
      n = n + 1
    end
  end
  return n
end

function Riven:IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function Riven:CountEnemiesInRange(point, range)
  if type(point) ~= "userdata" then error("{CountEnemiesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
  local range = range == nil and math.huge or range 
  if type(range) ~= "number" then error("{CountEnemiesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
  local n = 0
  for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if IsValidTarget(unit, range, true, point) then
      n = n + 1
    end
  end
  return n
end

function Riven:GetSpellInterceptTime(startPos, endPos, delay, speed)	
	local interceptTime = Game.Latency()/2000 + delay + self:GetDistance(startPos, endPos) / speed
	return interceptTime
end

function Riven:CalculatePhysicalDamage(target, damage)			
	local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
	local damageReduction = 100 / ( 100 + targetArmor)
	if targetArmor < 0 then
		damageReduction = 2 - (100 / (100 - targetArmor))
	end		
	damage = damage * damageReduction	
	return damage
end

-- CASTING #############################

function Riven:CastSpell(spell,pos)
	local customcast = self.Menu.CustomSpellCast:Value()
	if not customcast then
		_G.Control.CastSpell(spell, pos)
		return
	else
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		local mylvl = myHero.levelData.lvl-1
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				--block movement
				if _G.SDK then 
					_G.SDK.Orbwalker:SetMovement(false)
					_G.SDK.Orbwalker:SetAttack(false)
				end
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/400 - (3.5 * mylvl),{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end



function Riven:CastFlee()

if self:CanCast(_Q) or self:CanCast(_E) then

	if self:CanCast(_Q) then
	RightMoves(cursorPos)
	DelayAction(_G.Control.CastSpell(HK_Q, cursorPos), 0.75)
	_G.Control.CastSpell(HK_Q, cursorPos)
	end
	if self:CanCast(_E) then
	self:CastSpell(HK_E, cursorPos)
	end

end

end

function Riven:CastQ(target)
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AD"))
	if target and target.type == "AIHeroClient" and self:CanCast(_Q) and target.valid then
		local castPos		
		castPos = target:GetPrediction(Q.Speed, Q.Delay)
		self:CastSpell(HK_Q, castPos)
		
	end
end

function Riven:CastAA(target)
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(AARange , _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(AARange,"AD"))
	if target and target.type == "AIHeroClient" and target.valid then 
		_G.Control.Attack(target)
	end
end

function Riven:CastAADelayed(target)
	local delay = self.Menu.delay:Value()
	local mylvl = myHero.levelData.lvl-1
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(AARange , _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(AARange,"AD"))
	if target and target.type == "AIHeroClient" and target.valid then 
		DelayAction(_G.Control.Attack(target),delay/400 - (3.5 * mylvl))
		_G.Control.Attack(target)
	end
end


function Riven:CastW()
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(W.Range,"AD"))
	if target and target.type == "AIHeroClient" and self:CanCast(_W) and target.valid then
		local castPos
		castPos = target:GetPrediction(W.Speed,W.Delay)
		_G.Control.CastSpell(HK_W, castPos)
	end
end

function Riven:CastE()
	if self:CanCast(_E) then
		_G.Control.CastSpell(HK_E,mousePos.x,mousePos.y,mousePos.z)
	end
end

function Riven:CastR(target)
	self:CastSpell(HK_R,target)
end

function Riven:IsAttacking()
	if myHero.attackData and myHero.attackData.target and myHero.attackData.state == STATE_WINDUP then return true end
	return false
end

function Riven:IsUnknown()
	if myHero.attackData and myHero.attackData.target and myHero.attackData.state == STATE_UNKNOWN then return true end
	return false
end

local FoodTable = {
	SRU_Baron = "",
	SRU_RiftHerald = "",
	SRU_Dragon_Water = "",
	SRU_Dragon_Fire = "",
	SRU_Dragon_Earth = "",
	SRU_Dragon_Air = "",
	SRU_Dragon_Elder = "",
}

function Riven:IsReady(spellSlot)
	
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Riven:CanCast(spellSlot)
	return self:IsReady(spellSlot)
end

function Riven:PredictReactionTime(unit, minimumReactionTime)
	local reactionTime = minimumReactionTime
	
	--If the target is auto attacking increase their reaction time by .15s - If using a skill use the remaining windup time
	if unit.activeSpell and unit.activeSpell.valid then
		local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer()
		if windupRemaining > 0 then
			reactionTime = windupRemaining
		end
	end	
	return reactionTime
end

--DRAW #############################

function Riven:Draw()
	if myHero.dead then return end 
	
	if self.Menu.DrawMenu.DrawQ:Value() then
		Draw.Circle(myHero.pos, Q.Range, 3, self.Menu.DrawMenu.QRangeC:Value())
	end
	if self.Menu.DrawMenu.DrawW:Value() then
		Draw.Circle(myHero.pos, W.Range, 3, self.Menu.DrawMenu.WRangeC:Value())
	end
	
	if self.Menu.DrawMenu.DrawE:Value() then
		Draw.Circle(myHero.pos, E.Range, 3, self.Menu.DrawMenu.ERangeC:Value())
	end
	
	if self.Menu.DrawMenu.DrawR:Value() then
		Draw.Circle(myHero.pos, R.Range, 3, self.Menu.DrawMenu.RRangeC:Value())
	end
end
function OnLoad()
	Riven()
end
