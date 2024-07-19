#=============================================================================
# Accuracy Calculation
#=============================================================================
class Battle::Move
  def pbAccuracyCheck(user, target)
    # "Always hit" effects and "always hit" accuracy
    return true if target.effects[PBEffects::Telekinesis] > 0
    return true if target.effects[PBEffects::Minimize] && tramplesMinimize? && Settings::MECHANICS_GENERATION >= 6
    baseAcc = pbBaseAccuracy(user, target)
    return true if baseAcc == 0
    # Calculate all multiplier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
	  modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user, target, modifiers)
    # Check if move can't miss
    return true if modifiers[:base_accuracy] == 0
#============================================================================= 02 Grassy Field
	if [:GrassyTerrain].include?(@battle.field.terrain) && [:GRASSWHISTLE].include?(@id)
		modifiers[:base_accuracy] = 80
	end
#============================================================================= 03 Misty Field
	if [:MistyTerrain].include?(@battle.field.terrain) && [:SWEETKISS].include?(@id)
		modifiers[:base_accuracy] = 100
	end
#============================================================================= 04 Psychic Field
	if [:PsychicTerrain].include?(@battle.field.terrain)
    if [:HYPNOSIS].include?(@id)
		  modifiers[:base_accuracy] = 90
    elsif [:MYSTICALPOWER].include?(@id)
      modifiers[:base_accuracy] = 100
    elsif statusMove? && target.hasActiveAbility?(:MAGICIAN)
      modifiers[:base_accuracy] = 50
    end
	end
#============================================================================= 06 Rocky Field
	if [:RockyField].include?(@battle.field.terrain)
		if [:STONEEDGE, :HEADSMASH].include?(@id)
			modifiers[:base_accuracy] = 90
		end
		if [:ROCKTHROW, :ROCKSLIDE, :ROLLOUT, :ROCKBLAST, :ROCKWRECKER].include?(@id)
			modifiers[:base_accuracy] = 95
		end
		if [:ROCKTOMB, :DIAMONDSTORM, :METEORBEAM, :STONEAXE].include?(@id)
			modifiers[:base_accuracy] = 100
		end
	end
#============================================================================= 07 Corrosive Field
	if [:CorrosiveField].include?(@battle.field.terrain)
		if [:POISONPOWDER, :SLEEPPOWDER, :STUNSPORE, :TOXIC].include?(@id)
			modifiers[:base_accuracy] = 100
		end
	end
  #============================================================================= 08 Corrosive Mist Field
	if [:CorrosiveField].include?(@battle.field.terrain)
		if [:TOXIC].include?(@id)
			modifiers[:base_accuracy] = 100
		end
	end
  #============================================================================= 09 Burning Field
	if [:BurningField].include?(@battle.field.terrain)
		if [:WILLOWISP].include?(@id)
			modifiers[:base_accuracy] = 100
		end
	end
#=============================================================================
    # Calculation
    max_stage = Battle::Battler::STAT_STAGE_MAXIMUM
    accStage = [[modifiers[:accuracy_stage], -max_stage].max, max_stage].min + max_stage
    evaStage = [[modifiers[:evasion_stage], -max_stage].max, max_stage].min + max_stage
    stageMul = Battle::Battler::ACC_EVA_STAGE_MULTIPLIERS
    stageDiv = Battle::Battler::ACC_EVA_STAGE_DIVISORS
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
    evasion  = (evasion  * modifiers[:evasion_multiplier]).round
    evasion = 1 if evasion < 1
    threshold = modifiers[:base_accuracy] * accuracy / evasion
    # Calculation
    r = @battle.pbRandom(100)
    if Settings::AFFECTION_EFFECTS && @battle.internalBattle &&
       target.pbOwnedByPlayer? && target.affection_level == 5 && !target.mega?
      return true if r < threshold - 10
      target.damageState.affection_missed = true if r < threshold
      return false
    end
    return r < threshold
  end
end