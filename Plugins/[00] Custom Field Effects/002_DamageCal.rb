class Battle::Move

  def pbBaseDamage(baseDmg, user, target)
		case @battle.field.terrain
#============================================================================= 01 Electric Terrain
			when :ElectricTerrain
				if type == :ELECTRIC && user.affectedByTerrain?
					baseDmg *= 1.3 
					@battle.pbDisplay(_INTL("The Electric Terrain strengthened the attack!"))
				end
				if [:EXPLOSION, :HURRICANE, :MUDDYWATER, :SELFDESTRUCT, :SMACKDOWN, :SURF, :THOUSANDARROWS]
					baseDmg *= 1.5
					@battle.pbDisplay(_INTL("The attack became hyper-charged!"))
				end
				if [:MAGNETBOMB].include?(@id)
					baseDmg *= 2
					@battle.pbDisplay(__INTL("The attack powered-up!"))
				end
#============================================================================= 02 Grassy Terrain
			when :GrassyTerrain
				if type == :GRASS && user.affectedByTerrain?
					baseDmg *= 1.3
					@battle.pbDisplay(_INTL("The Grassy Terrain strengthened the attack!"))
				end
				if type == :FIRE && target.affectedByTerrain?
					baseDmg *= 1.3
					@battle.pbDisplay(_INTL("The grass below caught flame!"))
				end
				if [:BULLDOZE, :EARTHQUAKE, :MAGNITUDE, :MUDDYWATER, :SURF].include?(@id)
					@battle.pbDisplay(_INTL("The grass softened the attack..."))
				end
				if [:FAIRYWIND, :SILVERWIND, :GUST, :ICYWIND, :OMINOUSWIND, :RAZORWIND, :TWISTER].include?(@id)
					baseDmg *= 1.5
					@battle.pbDisplay(_INTL("The wind picked up strength from the field!", target.pbThis))
				end
#============================================================================= 03 Misty Terrain
			when :MistyTerrain
				if type == :DRAGON && user.affectedByTerrain?
					baseDmg *= 0.5
					@battle.pbDisplay(_INTL("The Misty Terrain weakened the attack!"))
				end
				if type == :FAIRY && user.affectedByTerrain?
					baseDmg *= 1.3
					@battle.pbDisplay(_INTL("The Misty Terrain strengthened the attack!"))
				end
				if [:AURASPHERE, :DAZZLINGGLEAM, :DOOMDESIRE, :FAIRYWIND, :ICYWIND, :MAGICALLEAF, :MISTBALL, :MOONBLAST, 
					:MOONGEISTBEAM, :MYSTICALFIRE, :SILVERWIND, :STEAMERUPTION, :STRANGESTEAM, :SPRINGTIDESTORM].include?(@id)
					baseDmg *= 1.5
					@battle.pbDisplay(_INTL("The mist's energy strengthened the attack!"))
				end
				if [:DARKPULSE, :NIGHTDAZE, :SHADOWBALL].include?(@id)
					baseDmg *= 0.5
					@battle.pbDisplay(_INTL("The mist softened the attack..."))
				end
#============================================================================= 04 Psychic Terrain
			when :PsychicTerrain
				if type == :PSYCHIC && user.affectedByTerrain?
					baseDmg *= 1.3
					@battle.pbDisplay(_INTL("The weirdness boosted the attack!"))
				end
				if [:EXPANDINGFORCE].include?(@id) && user.affectedByTerrain?
					@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the weirdness!", target.pbThis))
				end
				if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
					@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the weirdness!", target.pbThis))
				end
#============================================================================= 05 Inverse Field
			when :InverseField
				if type == :NORMAL && user.affectedByTerrain?
					baseDmg *= 1.5
					@battle.pbDisplay(_INTL("!kcatta eht detsoob dleif ehT"))
				end
				if user.hasActiveAbility?(:NORMALIZE) && powerBoost
					baseDmg *= 1.25
					@battle.pbShowAbilitySplash(user)
					@battle.pbDisplay(_INTL("!dleif eht yb decnahne saw {1} no kcatta ehT", target.pbThis))
					@battle.pbHideAbilitySplash(user)	
				end
#============================================================================= 06 Rocky Field
			when :RockyField
				if type == :ROCK && user.affectedByTerrain?
					baseDmg *= 1.3
					@battle.pbDisplay(_INTL("The rock boosted the attack on {1}!", target.pbThis))
				end
				if [:ROCKSMASH].include?(@id) && user.affectedByTerrain?
					baseDmg *= 2
					@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the rock!", target.pbThis))
				end
#============================================================================= 07 Corrosive Field
			when :CorrosiveField
				if [:VENOSHOCK].include?(@id)
					baseDmg = 130
				end
				if [:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDDYWATER, :WHIRLPOOL, :THOUSANDARROWS].include?(@id)
					@battle.pbDisplay(_INTL("The corrosion strengthened the attack!"))
					baseDmg *= 1.5
				end
				if [:ACID, :ACIDSPRAY, :GRASSKNOT].include?(@id)
					@battle.pbDisplay(_INTL("The corrosion strengthened the attack!"))
					baseDmg *= 2
				end
#=============================================================================
			end
    return baseDmg
  end
end