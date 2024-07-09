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
    if [:RockyField].include?(@battle.field.terrain) && GameData::Type.exists?(:ROCK) && 
	   [:EARTHQUAKE, :MAGNITUDE, :ROCKCLIMB, :STRENGTH, :BULLDOZE, :HEADBUTT].include?(@id)
	ret = :ROCK
	end
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
#============================================================================= Electric Field
	if [:ElectricField].include?(@battle.field.terrain) &&
       [:EXPLOSION, :SELFDESTRUCT, :SURF, :MUDDYWATER, :HURRICANE, :SMACKDOWN, :THOUSANDARROWS].include?(@id) && 
	   GameData::Type.exists?(:ELECTRIC)
       ret += Effectiveness.calculate(:ELECTRIC, defType)
    end
#============================================================================= 
=begin	
	if GameData::Type.exists?(:WATER) && moveType == :ELECTRIC # multiply type effectiveness cal
       ret *= Effectiveness.calculate(:WATER, defType)
    end
	if GameData::Type.exists?(:WATER) && moveType == :ELECTRIC # additional type effectiveness cal
       ret += Effectiveness.calculate(:WATER, defType)
    end	
	if GameData::Type.exists?(:WATER) && moveType == :ELECTRIC # change type effectiveness cal
       ret = Effectiveness.calculate(:WATER, defType)
    end
=end
#============================================================================= Electric Terrain
	if [:ElectricTerrain, :ElectricField].include?(@battle.field.terrain) &&
	   [:Rain, :HeavyRain].include?(target.effectiveWeather) && defType == :GROUND && moveType == :ELECTRIC
	   ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER # Electric Attack Ground Type Rain
	   if [:InverseField].include?(@battle.field.terrain) # Inverse Battle 2→0.5
       ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
	   end
	end
#============================================================================= Inverse Field
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

#============================================================================= Corrosive Field
	if [:CorrosiveField].include?(@battle.field.terrain)
		power = 130 if [:VENOSHOCK].include?(@id)
		
		if ([:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDDYWATER, :WHIRLPOOL, :THOUSANDARROWS].include?(@id) || moveType == :GRASS) && GameData::Type.exists?(:POISON)
			ret *= Effectiveness.calculate(:POISON, defType)
		end
	end
#=============================================================================
#=============================================================================
    return ret
  end
end
