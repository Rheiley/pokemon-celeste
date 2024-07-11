#=============================================================================
# Move Type Change
#=============================================================================
class Battle::Move
  def pbBaseType(user)
    ret = @type
    if ret && user.abilityActive?
      ret = Battle::AbilityEffects.triggerModifyMoveBaseType(user.ability, user, self, ret)
    end
#=============================================================================
    # if [:RockyField].include?(@battle.field.terrain) && GameData::Type.exists?(:ROCK) && 
	  # [:EARTHQUAKE, :MAGNITUDE, :ROCKCLIMB, :STRENGTH, :BULLDOZE, :HEADBUTT].include?(@id)
		# 	ret = :ROCK
		# end
#=============================================================================
    return ret
  end
end

#=============================================================================
# Type Effectiveness Calculation
#=============================================================================
class Battle::Move
  alias fieldEffects_pbCalcTypeModSingle pbCalcTypeModSingle
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = fieldEffects_pbCalcTypeModSingle(moveType, defType, user, target)
#============================================================================= 01 Electric Terrain
	if [:ElectricTerrain].include?(@battle.field.terrain)
		if [:EXPLOSION, :HURRICANE, :MUDDYWATER, :SELFDESTRUCT, :SMACKDOWN, :SURF, :THOUSANDARROWS, :PSYBLADE, :HYDROVORTEX].include?(@id) && GameData::Type.exists?(:ELECTRIC)
			ret *= Effectiveness.calculate(:ELECTRIC, defType)
		end
	end

#============================================================================= 
# =begin	
# 	if GameData::Type.exists?(:WATER) && moveType == :ELECTRIC # multiply type effectiveness cal
#        ret *= Effectiveness.calculate(:WATER, defType)
#     end
# 	if GameData::Type.exists?(:WATER) && moveType == :ELECTRIC # additional type effectiveness cal
#        ret += Effectiveness.calculate(:WATER, defType)
#     end	
# 	if GameData::Type.exists?(:WATER) && moveType == :ELECTRIC # change type effectiveness cal
#        ret = Effectiveness.calculate(:WATER, defType)
#     end
# =end
#=============================================================================

#============================================================================= 05 Inverse Field
	if Effectiveness.ineffective_type?(moveType, defType)
		if [:InverseField].include?(@battle.field.terrain) # Inverse Battle 0→2
			ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
		end
    elsif Effectiveness.super_effective_type?(moveType, defType)
		if [:InverseField].include?(@battle.field.terrain) # Inverse Battle 2→0.5
			ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
	    end
	elsif Effectiveness.not_very_effective_type?(moveType, defType)
		if [:InverseField].include?(@battle.field.terrain) # Inverse Battle 0.5→2
			ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
	    end	      
    end
#============================================================================= 06 Rocky Field
	if [:CorrosiveField].include?(@battle.field.terrain)		
		if [:RockyField].include?(@battle.field.terrain) && GameData::Type.exists?(:ROCK) && [:EARTHQUAKE, :MAGNITUDE, :ROCKCLIMB, :STRENGTH, :BULLDOZE].include?(@id)
			ret*= Effectiveness.calculate(:ROCK, defType)
		end
	end
#============================================================================= 07 Corrosive Field
	if [:CorrosiveField].include?(@battle.field.terrain)
		if ([:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDDYWATER, :WHIRLPOOL, :THOUSANDARROWS, :APPLEACID].include?(@id) || moveType == :GRASS) && GameData::Type.exists?(:POISON)
			ret *= Effectiveness.calculate(:POISON, defType)
		end
		if @type == :GRASS
			ret *= Effectiveness.calculate(:POISON, defType)
		end
	end
#============================================================================= 08 Corrosive Mist Field
	if [:CorrosiveMistField].include?(@battle.field.terrain)
		if ((moveType == :FLYING && specialMove?) || [:APPLEACID, :BUBBLE, :BUBBLEBEAM, :SPARKLINGARIA, :ENERGYBALL].include?(@id)) && GameData::Type.exists?(:POISON)
			ret *= Effectiveness.calculate(:POISON, defType)
		end
	end
#=============================================================================
    return ret
  end
end
