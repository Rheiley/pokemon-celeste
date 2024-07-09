class Battle::Move

  def pbModifyDamage(damageMult, user, target)
	case @battle.field.terrain
#============================================================================= 01 Electric Terrain
    when :ElectricTerrain
		if type == :ELECTRIC && user.affectedByTerrain?
			damageMult *= 1.3 
			@battle.pbDisplay(_INTL("The current strengthened the attack!"))
		end
		if user.hasActiveAbility?(:HADRONENGINE) && specialMove?
			@battle.pbShowAbilitySplash(user)
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
			@battle.pbHideAbilitySplash(user)
		end
			if user.hasActiveAbility?(:GALVANIZE) && powerBoost
			@battle.pbShowAbilitySplash(user)
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
			@battle.pbHideAbilitySplash(user)
		end	
		if [:RISINGVOLTAGE].include?(@id) && target.affectedByTerrain?
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
		end
		if [:PSYBLADE].include?(@id)
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
		end
		
		if user.affectedByTerrain?
			if [:TERRAINPULSE].include?(@id)
				@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
			end
			if [:MAGNETBOMB].include?(@id)
				damageMult *= 2
				@battle.pbDisplay(__INTL("The magnetism strengthened the attack!"))
			end
		end
#============================================================================= 02 Grassy Terrain
	when :GrassyTerrain
		if type == :GRASS && user.affectedByTerrain?
			damageMult *= 1.3
			@battle.pbDisplay(_INTL("The grass strengthened the attack!"))
		end
		if [:GRASSYGLIDE].include?(@id) && user.affectedByTerrain?
			@battle.pbDisplay(_INTL("{1} moves faster on the grass!", @name))
		end
		if [:BULLDOZE, :EARTHQUAKE, :MAGNITUDE].include?(@id)
			@battle.pbDisplay(_INTL("The attack on {1} was weakened by the grass!", target.pbThis))
		end
		if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the grass!", target.pbThis))
		end
#============================================================================= 03 Misty Terrain
	when :MistyTerrain
		if type == :DRAGON && target.affectedByTerrain?
			damageMult *= 0.5
			@battle.pbDisplay(_INTL("The draconic power weakened..."))
		end
		if user.hasActiveAbility?(:PIXILATE) && powerBoost
			@battle.pbShowAbilitySplash(user)
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
			@battle.pbHideAbilitySplash(user)	
		end
		if [:MISTYEXPLOSION].include?(@id)
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
		end
		if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
		end
#============================================================================= 04 Psychic Terrain
    when :PsychicTerrain
		if type == :PSYCHIC && user.affectedByTerrain?
			damageMult *= 1.3
			@battle.pbDisplay(_INTL("The weirdness boosted the attack!"))
		end
			if [:EXPANDINGFORCE].include?(@id) && user.affectedByTerrain?
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the weirdness!", target.pbThis))
		end
			if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the weirdness!", target.pbThis))
	end
#============================================================================= 05 Electric Field
    when :ElectricField
		if type == :ELECTRIC && user.affectedByTerrain?
			damageMult *= 1.3
			@battle.pbDisplay(_INTL("The current strengthened the attack!"))
		end	
		if user.hasActiveAbility?(:HADRONENGINE) && specialMove?
			damageMult *= 4 / 3.0
			@battle.pbShowAbilitySplash(user)
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
			@battle.pbHideAbilitySplash(user)	
		end
		if user.hasActiveAbility?(:GALVANIZE) && powerBoost
			damageMult *= 1.25
			@battle.pbShowAbilitySplash(user)
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
			@battle.pbHideAbilitySplash(user)
		end	
		if user.isSpecies?(:ZAPDOS)
			damageMult *= 1.5
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))	
		end
		if user.isSpecies?(:MAGNEMITE)
			damageMult *= 2
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))	
		end	
		if [:EXPLOSION, :SELFDESTRUCT, :SURF, :MUDDYWATER, :HURRICANE, :SMACKDOWN, :THOUSANDARROWS].include?(@id) && user.affectedByTerrain?
			damageMult *= 1.3
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
		end
		if [:PSYBLADE].include?(@id)
			damageMult *= 1.5
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
		end
		if [:TERRAINPULSE, :MAGNETBOMB, :PLASMAFISTS].include?(@id) && user.affectedByTerrain?
			damageMult *= 2
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
		end 
		if [:RISINGVOLTAGE].include?(@id) && target.affectedByTerrain?
			damageMult *= 2
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
		end
		if type == :ELECTRIC && target.affectedByTerrain? && [:PARALYSIS].include?(target.status)
			damageMult *= 1.3
			@battle.pbDisplay(_INTL("{1} was hurt even more because its paralysis!", target.pbThis))
		end	
#============================================================================= 06 Grassy Field
	when :GrassyField
		if type == :GRASS && user.affectedByTerrain?
			damageMult *= 1.5
			@battle.pbDisplay(_INTL("The grass strengthened the attack!"))
		end
		if type == :FIRE && target.affectedByTerrain?
			damageMult *= 1.5
			@battle.pbDisplay(_INTL("The fire burned the grass!"))
		end
		if [:GRASSYGLIDE].include?(@id) && user.affectedByTerrain?
			@battle.pbDisplay(_INTL("{1} moves faster on the grass!", @name))
		end
		if [:BULLDOZE, :EARTHQUAKE, :MAGNITUDE, :SURF, :MUDDYWATER].include?(@id)
			damageMult *= 0.5
			@battle.pbDisplay(_INTL("The attack on {1} was weakened by the grass!", target.pbThis))
		end
		if [:FAIRYWIND, :SILVERWIND].include?(@id)
			damageMult *= 1.5
			@battle.pbDisplay(_INTL("The wind blew the grass up!"))
		end
		if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
			damageMult *= 2
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the grass!", target.pbThis))
		end
		if target.hasActiveAbility?(:GRASSPELT)
			multipliers[:defense_multiplier] *= 1.5
			@battle.pbShowAbilitySplash(target)
			@battle.pbDisplay(_INTL("The grass protected {1}!", target.pbThis))
			@battle.pbHideAbilitySplash(target)
		end
#============================================================================= 07 Misty Field
	when :MistyField
		if target.pbHasType?(:FAIRY) && target.affectedByTerrain? && specialMove?
			multipliers[:defense_multiplier] *= 1.5
			@battle.pbDisplay(_INTL("The mist protected {1}!", target.pbThis))
		end
		if type == :DRAGON && target.affectedByTerrain?
			damageMult *= 0.5
			@battle.pbDisplay(_INTL("The draconic power weakened..."))
		end
		if type == :FAIRY && user.affectedByTerrain?
			damageMult *= 1.5
			@battle.pbDisplay(_INTL("The mist strengthened the attack!"))
		end
		if target.hasActiveAbility?(:MARVELSCALE)
			multipliers[:defense_multiplier] *= 1.5
			@battle.pbShowAbilitySplash(target)
			@battle.pbDisplay(_INTL("The mist protected {1}!", target.pbThis))
			@battle.pbHideAbilitySplash(target)
		end
		if user.hasActiveAbility?(:PIXILATE) && powerBoost
			damageMult *= 1.25
			@battle.pbShowAbilitySplash(user)
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
			@battle.pbHideAbilitySplash(user)	
		end
		if [:DARKPULSE, :NIGHTDAZE,:SHADOWBALL].include?(@id)
			damageMult *= 0.5
			@battle.pbDisplay(_INTL("The attack on {1} was weakened by the mist!", target.pbThis))
		end
		if [:MISTYEXPLOSION, :MYSTICALFIRE, :MAGICALLEAF, :DOOMDESIRE, :HIDDENPOWER, :ICYWIND, :AURASPHERE].include?(@id) ||
		   [:MISTBALL, :STEAMERUPTION, :CLEARSMOG, :SMOG, :SILVERWIND, :STRANGESTEAM, :MOONGEISTBEAM].include?(@id)
			damageMult *= 1.5
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
		end
		if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
			damageMult *= 2
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
		end
#============================================================================= 08 Psychic Field
    when :PsychicField
		if type == :PSYCHIC && user.affectedByTerrain?
			damageMult *= 1.5
			@battle.pbDisplay(_INTL("The weirdness boosted the attack!"))
		end
		if [:EXPANDINGFORCE, :MYSTICALFIRE, :MAGICALLEAF, :AURASPHERE, :HEX, :MOONBLAST, :MINDBLOWN].include?(@id) && user.affectedByTerrain?
			damageMult *= 1.5
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the weirdness!", target.pbThis))
		end
		if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
			damageMult *= 2
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the weirdness!", target.pbThis))
		end
#============================================================================= 09 Inverse Field
    when :InverseField
		if type == :NORMAL && user.affectedByTerrain?
			damageMult *= 1.5
			@battle.pbDisplay(_INTL("!kcatta eht detsoob dleif ehT"))
		end
		if user.hasActiveAbility?(:NORMALIZE) && powerBoost
			damageMult *= 1.25
			@battle.pbShowAbilitySplash(user)
			@battle.pbDisplay(_INTL("!dleif eht yb decnahne saw {1} no kcatta ehT", target.pbThis))
			@battle.pbHideAbilitySplash(user)	
		end
#============================================================================= 10 Rocky Field
    when :RockyField
		if [:TERRAINPULSE].include?(@id)
			@type = :ROCK
			end
		if type == :ROCK && user.affectedByTerrain?
			damageMult *= 1.3
			@battle.pbDisplay(_INTL("The rock boosted the attack on {1}!", target.pbThis))
		end
		if [:TERRAINPULSE, :ROCKSMASH].include?(@id) && user.affectedByTerrain?
			damageMult *= 2
			@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the rock!", target.pbThis))
		end
#============================================================================= 11 Corrosive Field
    when :CorrosiveField
		if [:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDDYWATER, :WHIRLPOOL, :THOUSANDARROWS].include?(@id)
			@battle.pbDisplay(_INTL("The corrosion strengthened the attack!"))
			damageMult *= 1.5
		end
		if [:ACID, :ACIDSPRAY, :GRASSKNOT].include?(@id)
			@battle.pbDisplay(_INTL("The corrosion strengthened the attack!"))
			damageMult *= 2
		end
#=============================================================================
    end
    return damageMult
  end
end