#=============================================================================
# Status Immunity
#=============================================================================
class Battle::Battler
  alias fieldEffects_pbCanInflictStatus? pbCanInflictStatus?
  def pbCanInflictStatus?(newStatus, user, showMessages, move = nil, ignoreStatus = false)
#===============================================================================
    if [:ElectricTerrain, :ElectricField].include?(@battle.field.terrain) && affectedByTerrain? &&
    newStatus == :SLEEP
    @battle.pbDisplay(_INTL("{1} surrounds itself with electrified battlefield!", pbThis(true))) if showMessages
	return false
	end
    if [:MistyTerrain, :MistyField].include?(@battle.field.terrain) && affectedByTerrain?
	@battle.pbDisplay(_INTL("{1} surrounds itself with misty battlefield!", pbThis(true))) if showMessages
	return false
	end
=begin
	  newStatus == :FROZEN && isSpecies?(:IRONVALIANT)
	  @battle.pbDisplay(_INTL("The example field protected {1} from being frozen!", pbThis(true))) if showMessages
	  return false
	  end
=end
#===============================================================================
  ret = fieldEffects_pbCanInflictStatus?(newStatus, user, showMessages, move, ignoreStatus)
  ret
  end
end

#=============================================================================
# Yawn Immunity
#=============================================================================
class Battle::Battler
   alias fieldEffects_pbCanSleepYawn? pbCanSleepYawn?
   def pbCanSleepYawn?
#=============================================================================
    if [:ElectricTerrain, :ElectricField, :MistyTerrain, :MistyField].include?(@battle.field.terrain) && affectedByTerrain?
	@battle.pbDisplay(_INTL("{1} surrounds itself with battlefield!", pbThis(true)))
	return false
	end
#=============================================================================
   ret = fieldEffects_pbCanSleepYawn?
   ret
   end
end

#=============================================================================
# Confusion Immunity
#=============================================================================
class Battle::Battler	
   alias fieldEffects_pbCanConfuse? pbCanConfuse?
   def pbCanConfuse?(user = nil, showMessages = true, move = nil, selfInflicted = false)
#===============================================================================
     if [:MistyTerrain, :MistyField].include?(@battle.field.terrain) && affectedByTerrain?
	 @battle.pbDisplay(_INTL("{1} surrounds itself with misty battlefield!", pbThis(true))) if showMessages
	 return false
	 end
#===============================================================================
   ret = fieldEffects_pbCanConfuse?(user, showMessages, move, selfInflicted)
   ret
   end
end

#=============================================================================
# Synchronize Immunity
#=============================================================================
class Battle::Battler	
   alias fieldEffects_pbCanSynchronizeStatus? pbCanSynchronizeStatus?
   def pbCanSynchronizeStatus?(newStatus, user)
#===============================================================================
     if [:MistyTerrain, :MistyField].include?(@battle.field.terrain) && affectedByTerrain?
	 @battle.pbDisplay(_INTL("{1} surrounds itself with misty battlefield!", pbThis(true)))
	 return false
	 end
#===============================================================================
   ret = fieldEffects_pbCanSynchronizeStatus?(newStatus, user)
   ret
   end
end

#=============================================================================
# Moves Immunity
#=============================================================================
class Battle::Battler
  alias fieldEffects_pbSuccessCheckAgainstTarget pbSuccessCheckAgainstTarget
  def pbSuccessCheckAgainstTarget(move, user, target, targets)
    show_message = move.pbShowFailMessages?(targets)
    typeMod = move.pbCalcTypeMod(move.calcType, user, target)
    target.damageState.typeMod = typeMod
#===============================================================================
    if [:PsychicTerrain, :PsychicField].include?(@battle.field.terrain) && target.affectedByTerrain? &&
	   target.opposes?(user) && @battle.choices[user.index][4] > 0 # Move priority saved from pbCalculatePriority
	   @battle.pbDisplay(_INTL("{1} surrounds itself with psychic battlefield!", target.pbThis(true))) if show_message
    return false
    end
#===============================================================================
    if [:RockyField].include?(@battle.field.terrain) && target.affectedByTerrain? && target.pbHasType?(:ROCK) &&
	   target.opposes?(user) && @battle.choices[user.index][4] > 0 # Move priority saved from pbCalculatePriority
	   @battle.pbDisplay(_INTL("{1} surrounds itself with rocky battlefield!", target.pbThis(true))) if show_message
    return false
    end
#===============================================================================
#===============================================================================
  ret = fieldEffects_pbSuccessCheckAgainstTarget(move, user, target, targets)
  ret
  end
end