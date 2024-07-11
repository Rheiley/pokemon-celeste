class Battle::Move

  def pbBaseDamage(baseDmg, user, target)
		case @battle.field.terrain
#============================================================================= 01 Electric Terrain
			when :ElectricTerrain
				if type == :ELECTRIC && user.affectedByTerrain?
					baseDmg *= 1.3 
					@battle.pbDisplay(_INTL("The Electric Terrain strengthened the attack!"))
				end
				if [:EXPLOSION, :HURRICANE, :MUDDYWATER, :SELFDESTRUCT, :SMACKDOWN, :SURF, :THOUSANDARROWS, :PSYBLADE].include?(@id)
					baseDmg *= 1.5 if ![:PSYBLADE].include?(@id) # Psyblade is already boosted in ElectricTerrain (Gen 9 Pack)
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
					@battle.pbDisplay(_INTL("The Psychic Terrain strengthened the attack!"))
				end
				if [:EXPANDINGFORCE, :TERRAINPULSE].include?(@id) && user.affectedByTerrain?
					@battle.pbDisplay(_INTL("The psychic energy strengthened the attack!"))
				end
				if [:AURASPHERE, :FOCUSBLAST, :HEX, :HIDDENPOWER, :MAGICALLEAF, :MINDBLOWN, :MYSTICALFIRE, :SECRETPOWER].include?(@id)
					baseDmg *= 1.5
					@battle.pbDisplay(_INTL("The psychic energy strengthened the attack!"))
				end
#============================================================================= 05 Inverse Field

#============================================================================= 06 Rocky Field
			when :RockyField
				if type == :ROCK && user.affectedByTerrain?
					baseDmg *= 1.3
					@battle.pbDisplay(_INTL("The field strengthened the attack!"))
				end
				if [:ROCKSMASH].include?(@id) && user.affectedByTerrain?
					baseDmg *= 2
					@battle.pbDisplay(_INTL("SMASH'D!"))
				end
				if [:ACCELEROCK, :BULLDOZE, :EARTHQUAKE, :MAGNITUDE, :ROCKCLIMB, :STRENGTH].include?(@id) && user.affectedByTerrain?
					baseDmg *= 1.5
					@battle.pbDisplay(_INTL("The rocks strengthened the attack!"))
				end
#============================================================================= 07 Corrosive Field
			when :CorrosiveField
				if [:VENOSHOCK].include?(@id)
					baseDmg = 130
				end
				if [:BARBBARRAGE].include?(@id)
					baseDmg = 120
				end
				if [:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDDYWATER, :WHIRLPOOL, :THOUSANDARROWS, :APPLEACID].include?(@id)
					@battle.pbDisplay(_INTL("The corrosion strengthened the attack!"))
					baseDmg *= 1.5
				end
				if [:ACID, :ACIDSPRAY, :GRASSKNOT, :SNAPTRAP].include?(@id)
					@battle.pbDisplay(_INTL("The corrosion strengthened the attack!"))
					baseDmg *= 2
				end
#============================================================================= 08 Corrosive Mist Field
			when :CorrosiveMistField
				if type == :FIRE
					baseDmg *= 1.5
					@battle.pbDisplay(_INTL("The toxic mist caught flame!"))
				end
				if [:ACIDSPRAY, :APPLEACID, :BUBBLE, :BUBBLEBEAM, :CLEARSMOG, :SMOG, :SPARKLINGARIA].include?(@id)
					baseDmg *= 1.5
					@battle.pbDisplay(_INTL("The poison strengthened the attack!"))
				end
				if [:VENOSHOCK].include?(@id)
					baseDmg = 130
				end
				if [:BARBBARRAGE].include?(@id)
					baseDmg = 120
				end
#=============================================================================
			end
    return baseDmg
  end
end