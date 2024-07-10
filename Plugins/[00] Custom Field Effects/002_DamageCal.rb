class Battle::Move

  def pbBaseDamage(baseDmg, user, target)
		case @battle.field.terrain
#============================================================================= 01 Electric Terrain
			when :ElectricTerrain
				if type == :ELECTRIC && user.affectedByTerrain?
					baseDmg *= 1.3 
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
						baseDmg *= 2
						@battle.pbDisplay(__INTL("The magnetism strengthened the attack!"))
					end
				end
#============================================================================= 02 Grassy Terrain
			when :GrassyTerrain
				if type == :GRASS
					if user.affectedByTerrain?
						if [:GRASSYGLIDE].include?(@id)
							@battle.pbDisplay(_INTL("{1} moves faster on the grass!", @name))
						end
						baseDmg *= 1.3
						@battle.pbDisplay(_INTL("The grass strengthened the attack!"))
					end
				end
				if type == :FIRE
					if target.affectedByTerrain?
						baseDmg *= 1.3
						@battle.pbDisplay(_INTL("The grass below caught flame!"))
					end
				end
				if [:BULLDOZE, :EARTHQUAKE, :MAGNITUDE, :MUDDYWATER, :SURF].include?(@id)
					@battle.pbDisplay(_INTL("The attack on {1} was weakened by the grass!", target.pbThis))
				end
				if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
					@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the grass!", target.pbThis))
				end
				if [:FAIRYWIND, SILVERWIND].include?(@id)
					baseDmg *= 1.5
					@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the grass!", target.pbThis))
				end
#============================================================================= 03 Misty Terrain
			when :MistyTerrain
				if type == :DRAGON && target.affectedByTerrain?
					baseDmg *= 0.5
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
				if [:AURASPHERE, :DAZZLINGGLEAM, :DOOMDESIRE, :FAIRYWIND, :ICYWIND, :MAGICALLEAF, :MISTBALL, :MOONBLAST, :MOONGEISTBEAM, :MYSTICALFIRE, :SILVERWIND, :STEAMERUPTION].include?(@id)
					baseDmg *= 1.5
					@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
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