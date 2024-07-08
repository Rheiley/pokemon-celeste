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
#============================================================================= 06
	if [:GrassyField].include?(@battle.field.terrain) &&
	   [:GRASSWHISTLE].include?(@id)
	modifiers[:base_accuracy] == 80
	@battle.pbDisplay(_INTL("The grass leads the attack on {1}!", target.pbThis))
	end
#============================================================================= 07
	if [:MistyField].include?(@battle.field.terrain) &&
	   [:SWEETKISS].include?(@id)
	modifiers[:base_accuracy] == 100
	@battle.pbDisplay(_INTL("The mist leads the attack on {1}!", target.pbThis))
	end
#============================================================================= 08
	if [:PsychicField].include?(@battle.field.terrain) &&
	   [:HYPNOSIS].include?(@id)
	modifiers[:base_accuracy] == 90
	@battle.pbDisplay(_INTL("The weirdness leads the attack on {1}!", target.pbThis))
	end
#============================================================================= 10
	if [:RockyField].include?(@battle.field.terrain) &&
	   [:STONEEDGE, :HEADSMASH].include?(@id)
	modifiers[:base_accuracy] == 90
	@battle.pbDisplay(_INTL("The rock leads the attack on {1}!", target.pbThis))
	end
	if [:RockyField].include?(@battle.field.terrain) &&
	   [:ROCKTHROW, :ROCKSLIDE, :ROLLOUT, :ROCKBLAST, :ROCKWRECKER].include?(@id)
	modifiers[:base_accuracy] == 95
	@battle.pbDisplay(_INTL("The rock leads the attack on {1}!", target.pbThis))
	end
	if [:RockyField].include?(@battle.field.terrain) &&
	   [:ROCKTOMB, :DIAMONDSTORM, :METEORBEAM, :STONEAXE].include?(@id)
	modifiers[:base_accuracy] == 100
	@battle.pbDisplay(_INTL("The rock leads the attack on {1}!", target.pbThis))
	end
#============================================================================= 11
	if [:CorrosiveField].include?(@battle.field.terrain) &&
		[:POISONPOWDER, :SLEEPPOWDER, :STUNSPORE, :TOXIC].include?(@id)
		modifiers[:base_accuracy] = 100
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