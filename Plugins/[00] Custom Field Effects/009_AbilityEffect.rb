#===============================================================================
# Abilities Affected

# Electric Surge
Battle::AbilityEffects::OnSwitchIn.add(:ELECTRICSURGE,
  proc { |ability, battler, battle, switch_in|
	next if ![:None, :GrassyTerrain, :MistyTerrain, :PsychicTerrain].include?(battle.field.terrain)
    battle.pbShowAbilitySplash(battler)
	pbWait(0.5)
    battle.pbStartTerrain(battler, :ElectricTerrain)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

# Surge Surfer
Battle::AbilityEffects::SpeedCalc.add(:SURGESURFER,
  proc { |ability, battler, mult|
    next mult * 2 if battler.battle.field.terrain == :ElectricTerrain
  }
)

# Galvanize
Battle::AbilityEffects::ModifyMoveBaseType.add(:GALVANIZE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:ELECTRIC)
    move.powerBoost = true
    next :ELECTRIC
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:GALVANIZE,
  proc { |ability, user, target, move, mults, power, type|
	if [:ElectricTerrain].include?(user.battle.field.terrain) && move.powerBoost
		mults[:power_multiplier] *= 1.5
	elsif move.powerBoost
		mults[:power_multiplier] *= 1.2
	end
  }
)

# Blaze
Battle::AbilityEffects::DamageCalcFromUser.add(:BLAZE,
  proc { |ability, user, target, move, mults, power, type|
    if (user.hp <= user.totalhp / 3 || [:BurningField].include?(user.battle.field.terrain)) && type == :FIRE
      mults[:attack_multiplier] *= 1.5
    end
  }
)

# Flash Fire
Battle::AbilityEffects::EndOfRoundEffect.add(:FLASHFIRE,
  proc { |ability, battler, battle|
    if battle.field.terrain == :BurningField && battler.affectedByTerrain? && !battler.effects[PBEffects::FlashFire]
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1}'s Flash Fire activated!", battler.pbThis))
      battler.effects[PBEffects::FlashFire] = true
      battle.pbHideAbilitySplash(battler)
    end
  }
)


# Flare Boost
Battle::AbilityEffects::DamageCalcFromUser.add(:FLAREBOOST,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.5 if (user.burned? || [:BurningField].include?(user.battle.field.terrain)) && move.specialMove?
  }
)

# Comatose
Battle::AbilityEffects::OnSwitchIn.add(:COMATOSE,
  proc { |ability, battler, battle, switch_in|
	next if [:ElectricTerrain].include?(battle.field.terrain)
	battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is drowsing!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::StatusImmunityNonIgnorable.add(:COMATOSE,
  proc { |ability, battler, status|
    next true if battler.isSpecies?(:KOMALA) && [:ElectricTerrain].include?(battler.battle.field.terrain)
  }
)

Battle::AbilityEffects::StatusCheckNonIgnorable.add(:COMATOSE,
  proc { |ability, battler, status|
    next false if !battler.isSpecies?(:KOMALA)
	next false if [:ElectricTerrain].include?(battler.battle.field.terrain)
    next true if status.nil? || status == :SLEEP
  }
)

# Toxic Boost
Battle::AbilityEffects::DamageCalcFromUser.add(:TOXICBOOST,
  proc { |ability, user, target, move, mults, power, type|
    if user.poisoned? && move.physicalMove? || [:CorrosiveField, :CorrosiveMistField].include?(user.battle.field.terrain)
      mults[:power_multiplier] *= 1.5
    end
  }
)

# Poison Heal
Battle::AbilityEffects::EndOfRoundHealing.add(:POISONHEAL,
  proc { |ability, battler, battle|
	if battler.poisoned?
		pb.ShowAbilitySplash(battler)
		battler.pbRecoverHP(battler.totalhp / 8, false)
		battle.pbDisplay(_INTL("{1} recovered HP from its poisoning!", battler.pbThis))
		pb.HideAbilitySplash(battler)
	end
	if [:CorrosiveField, :CorrosiveMistField].include?(battle.field.terrain) && !battler.airborne?
		battler.pbrecoverHP(battler.totalhp / 8, false)
		battle.pbDisplay(__INTL("{1} was healed by poison!", battle.pbThis))
	end
  }
)

# Merciless
Battle::AbilityEffects::CriticalCalcFromUser.add(:MERCILESS,
  proc { |ability, user, target, c|
    next 99 if [:CorrosiveField, :CorrosiveMistField].include?(user.battle.field.terrain) || target.poisoned?
  }
)

# Corrosion
Battle::AbilityEffects::DamageCalcFromUser.add(:CORROSION,
  proc { |ability, user, target, move, mults, power, type|
    if [:CorrosiveField, :CorrosiveMistField].include?(user.battle.field.terrain)
      mults[:power_multiplier] *= 1.5
    end
  }
)

# Gulp Missile
Battle::AbilityEffects::OnEndOfUsingMove.add(:GULPMISSILE,
  proc { |ability, user, targets, move, battle|
	next if ![:ElectricTerrain].include?(battle.field.terrain)
    next if !user.isSpecies?(:CRAMORANT)
    next if user.form != 0
    if move.id == :SURF || (move.id == :DIVE && move.chargingTurn)
    user.pbChangeForm(2, nil)
	end
  }
)

# Anticipation
Battle::AbilityEffects::OnSwitchIn.add(:ANTICIPATION,
  proc { |ability, battler, battle, switch_in|
    next if !battler.pbOwnedByPlayer?
    battlerTypes = battler.pbTypes(true)
    types = battlerTypes
    found = false
    battle.allOtherSideBattlers(battler.index).each do |b|
      b.eachMove do |m|
        next if m.statusMove?
        if types.length > 0
          moveType = m.type
          if Settings::MECHANICS_GENERATION >= 6 && m.function_code == "TypeDependsOnUserIVs"   # Hidden Power
            moveType = pbHiddenPower(b.pokemon)[0]
          end
          eff = Effectiveness.calculate(moveType, *types)
          next if Effectiveness.ineffective?(eff)
          next if !Effectiveness.super_effective?(eff) &&
                  !["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(m.function_code)
        elsif !["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(m.function_code)
          next
        end
        found = true
        break
      end
      break if found
    end
    if found
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} shuddered with anticipation!", battler.pbThis))
      battler.pbRaiseStatStage(:SPECIAL_ATTACK, 2, battler) 
      battle.pbHideAbilitySplash(battler)
    end
  }
)

# Forewarn
Battle::AbilityEffects::OnSwitchIn.add(:FOREWARN,
  proc { |ability, battler, battle, switch_in|
    next if !battler.pbOwnedByPlayer?
    highestPower = 0
    forewarnMoves = []
    battle.allOtherSideBattlers(battler.index).each do |b|
      b.eachMove do |m|
        power = m.power
        power = 160 if ["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(m.function_code)
        power = 150 if ["PowerHigherWithUserHP"].include?(m.function_code)    # Eruption
        # Counter, Mirror Coat, Metal Burst
        power = 120 if ["CounterPhysicalDamage",
                        "CounterSpecialDamage",
                        "CounterDamagePlusHalf"].include?(m.function_code)
        # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
        # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
        # Natural Gift, Trump Card, Flail, Grass Knot
        power = 80 if ["FixedDamage20",
                       "FixedDamage40",
                       "FixedDamageUserLevel",
                       "LowerTargetHPToUserHP",
                       "FixedDamageUserLevelRandom",
                       "PowerHigherWithUserHappiness",
                       "PowerLowerWithUserHappiness",
                       "PowerHigherWithUserHP",
                       "PowerHigherWithTargetFasterThanUser",
                       "TypeAndPowerDependOnUserBerry",
                       "PowerHigherWithLessPP",
                       "PowerLowerWithUserHP",
                       "PowerHigherWithTargetWeight"].include?(m.function_code)
        power = 80 if Settings::MECHANICS_GENERATION <= 5 && m.function_code == "TypeDependsOnUserIVs"
        next if power < highestPower
        forewarnMoves = [] if power > highestPower
        forewarnMoves.push(m.name)
        highestPower = power
      end
    end
    if forewarnMoves.length > 0
      battle.pbShowAbilitySplash(battler)
      forewarnMoveName = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} was alerted to {2}!",
        battler.pbThis, forewarnMoveName))
        battler.pbRaiseStatStage(:SPECIAL_ATTACK, 2, battler) 
      else
        battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",
        battler.pbThis, forewarnMoveName))
        battler.pbRaiseStatStage(:SPECIAL_ATTACK, 2, battler) 
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)


# Grassy Surge
Battle::AbilityEffects::OnSwitchIn.add(:GRASSYSURGE,
  proc { |ability, battler, battle, switch_in|
	next if ![:None, :ElectricTerrain, :MistyTerrain, :PsychicTerrain].include?(battle.field.terrain)
    battle.pbShowAbilitySplash(battler)
	  pbWait(0.5)
    battle.pbStartTerrain(battler, :GrassyTerrain)
  }
)

# Grass Pelt
Battle::AbilityEffects::DamageCalcFromTarget.add(:GRASSPELT,
  proc { |ability, user, target, move, mults, power, type|
    mults[:defense_multiplier] *= 1.5 if [:GrassyTerrain].include?(user.battle.field.terrain)
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:GRASSPELT,
  proc { |ability, battler, battle|
    if battler.battle.field.terrain == :CorrosiveField
        battle.pbShowAbilitySplash(battler)
		    battler.pbReduceHP(battler.totalhp / 8, false)
        battle.pbDisplay(_INTL("{1} is hurt by the corrosion!", battler.pbThis))
        battle.pbHideAbilitySplash(battler)
    end
  }
)

# Power Spot
Battle::AbilityEffects::DamageCalcFromAlly.add(:POWERSPOT,
  proc { |ability, user, target, move, mults, power, type|
    if [:PsychicTerrain].include?(user.battle.field.terrain)
      mults[:final_damage_multiplier] *= 1.5
    else
      mults[:final_damage_multiplier] *= 1.3
    end
  }
)

# Dry Skin
Battle::AbilityEffects::EndOfRoundEffect.add(:DRYSKIN,
  proc { |ability, battler, battle|
    if battler.battle.field.terrain == :DesertField
      battle.pbShowAbilitySplash(battler)
		  battler.pbReduceHP(battler.totalhp / 8, false)
      battle.pbHideAbilitySplash(battler)
    end
  }
)

# Sap Sipper
Battle::AbilityEffects::MoveImmunity.add(:SAPSIPPER,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :GRASS, :ATTACK, 1, show_message)
  }
)

# Cotton Down
Battle::AbilityEffects::OnBeingHit.add(:COTTONDOWN,
  proc { |ability, user, target, move, battle|
    next if battle.allBattlers.none? { |b| b.index != target.index && b.pbCanLowerStatStage?(:SPEED, target) }
    battle.pbShowAbilitySplash(target)
    battle.allBattlers.each do |b|
	 if [:GrassyTerrain].include?(battle.field.terrain) && b.affectedByTerrain?
       b.pbLowerStatStageByAbility(:SPEED, 2, target, false) if b.index != target.index
	 else
	 b.pbLowerStatStageByAbility(:SPEED, 1, target, false) if b.index != target.index
     end
	end
    battle.pbHideAbilitySplash(target)
  }
)


# Misty Surge
Battle::AbilityEffects::OnSwitchIn.add(:MISTYSURGE,
  proc { |ability, battler, battle, switch_in|
	next if ![:None, :ElectricTerrain, :GrassyTerrain, :PsychicTerrain].include?(battle.field.terrain)
    battle.pbShowAbilitySplash(battler)
	pbWait(0.5)
    battle.pbStartTerrain(battler, :MistyTerrain)
  }
)

# Marvel Scale
Battle::AbilityEffects::DamageCalcFromTarget.add(:MARVELSCALE,
  proc { |ability, user, target, move, mults, power, type|
    if target.pbHasAnyStatus? && move.physicalMove? || [:MistyTerrain].include?(user.battle.field.terrain)
      mults[:defense_multiplier] *= 1.5
    end
  }
)

# Soul Heart
Battle::AbilityEffects::OnBattlerFainting.add(:SOULHEART,
  proc { |ability, battler, fainted, battle|
    if [:MistyTerrain].include?(battle.field.terrain)
      battle.pbShowAbilitySplash(battler)
      battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 1, battler)
      battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler)
      battle.pbHideAbilitySplash(battler)
    else
      battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 1, battler)
    end  
  }
)

# Pixilate
Battle::AbilityEffects::ModifyMoveBaseType.add(:PIXILATE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:FAIRY)
    move.powerBoost = true
    next :FAIRY
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:PIXILATE,
  proc { |ability, user, target, move, mults, power, type|
    if [:MistyTerrain].include?(user.battle.field.terrain) && move.powerBoost
      mults[:power_multiplier] *= 1.5
    elsif move.powerBoost
      mults[:power_multiplier] *= 1.2
    end
  }
)

# Pastel Veil
Battle::AbilityEffects::DamageCalcFromTargetAlly.add(:PASTELVEIL,
  proc { |ability, user, target, move, mults, power, type|
    mults[:final_damage_multiplier] *= 0.5 if type == :POISON && target.battle.field.terrain == :MistyTerrain
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:PASTELVEIL,
  proc { |ability, user, target, move, mults, power, type|
    mults[:final_damage_multiplier] *= 0.5 if type == :POISON && target.battle.field.terrain == :MistyTerrain
  }
)

# Psychic Surge
Battle::AbilityEffects::OnSwitchIn.add(:PSYCHICSURGE,
  proc { |ability, battler, battle, switch_in|
    next if ![:None, :ElectricTerrain, :GrassyTerrain, :MistyTerrain].include?(battle.field.terrain)
	battle.pbShowAbilitySplash(battler)
	pbWait(0.5)
    battle.pbStartTerrain(battler, :PsychicTerrain)
  }
)

# Normalize
Battle::AbilityEffects::ModifyMoveBaseType.add(:NORMALIZE,
  proc { |ability, user, move, type|
    next if type == :NORMAL || !GameData::Type.exists?(:NORMAL)
    move.powerBoost = true if Settings::MECHANICS_GENERATION >= 7
    next :NORMAL
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:NORMALIZE,
  proc { |ability, user, target, move, mults, power, type|
	mults[:power_multiplier] *= 1.2 if move.powerBoost
  }
)


# Long Reach
Battle::AbilityEffects::AccuracyCalcFromUser.add(:LONGREACH,
  proc { |ability, mods, user, target, move, type|
    mods[:accuracy_multiplier] *= 0.9 if user.battle.field.terrain == :RockyField
  }
)

# Sand Stream
Battle::AbilityEffects::OnSwitchIn.add(:SANDSTREAM,
  proc { |ability, battler, battle, switch_in|
    battle.pbStartWeatherAbility(:Sandstorm, battler)
  }
)

# Sand Force
Battle::AbilityEffects::DamageCalcFromUser.add(:SANDFORCE,
  proc { |ability, user, target, move, mults, power, type|
    if (user.effectiveWeather == :Sandstorm || user.battle.field.terrain == :DesertField) &&
       [:ROCK, :GROUND, :STEEL].include?(type)
      mults[:power_multiplier] *= 1.3
    end
  }
)

# Sand Rush
Battle::AbilityEffects::SpeedCalc.add(:SANDRUSH,
  proc { |ability, battler, mult|
    if [:Sandstorm].include?(battler.effectiveWeather) || battler.battle.field.terrain == :DesertField
      next mult * 2
    end
  }
)

# Sand Veil
Battle::AbilityEffects::AccuracyCalcFromTarget.add(:SANDVEIL,
  proc { |ability, mods, user, target, move, type|
    if target.effectiveWeather == :Sandstorm || target.battle.field.terrain == :DesertField
      mods[:evasion_multiplier] *= 1.25
    end
  }
)

# Battle Armor
Battle::AbilityEffects::CriticalCalcFromTarget.add(:BATTLEARMOR,
  proc { |ability, user, target, c|
    next -1
  }
)

Battle::AbilityEffects::OnBeingHit.add(:BATTLEARMOR,
  proc { |ability, user, target, move, battle|
    next if ![:RockyField].include?(battle.field.terrain)
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp / 8, false)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!", user.pbThis,
           target.pbThis(true), target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

# Shell Armor
Battle::AbilityEffects::CriticalCalcFromTarget.copy(:BATTLEARMOR, :SHELLARMOR)

Battle::AbilityEffects::OnBeingHit.copy(:BATTLEARMOR, :SHELLARMOR)

# Defeatist
Battle::AbilityEffects::DamageCalcFromUser.add(:DEFEATIST,
  proc { |ability, user, target, move, mults, power, type|
    next if [:RockyField].include?(user.battle.field.terrain)
    mults[:power_multiplier] /= 2 if user.hp <= user.totalhp / 2
  }
)

# Refrigerate
Battle::AbilityEffects::ModifyMoveBaseType.add(:REFRIGERATE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:ICE)
    move.powerBoost = true
    next :ICE
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:REFRIGERATE,
  proc { |ability, user, target, move, mults, power, type|
	mults[:power_multiplier] *= 1.2 if move.powerBoost
  }
)

# Aerilate
Battle::AbilityEffects::ModifyMoveBaseType.add(:AERILATE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:FLYING)
    move.powerBoost = true
    next :FLYING
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:AERILATE,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if move.powerBoost
  }
)

# Motor Drive
Battle::AbilityEffects::EndOfRoundEffect.add(:MOTORDRIVE,
  proc { |ability, battler, battle|
    if [:ElectricTerrain].include?(battler.battle.field.terrain)
      battler.pbRaiseStatStageByAbility(:SPEED, 1, battler)
    end
  }
)

#=============================================================================== All Field
# Mimicry
Battle::AbilityEffects::OnSwitchIn.add(:MIMICRY,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :None
    Battle::AbilityEffects.triggerOnTerrainChange(ability, battler, battle, false)
  }
)

Battle::AbilityEffects::OnTerrainChange.add(:MIMICRY,
  proc { |ability, battler, battle, ability_changed|
    if battle.field.terrain == :None
      # Revert to original typing
      battle.pbShowAbilitySplash(battler)
      battler.pbResetTypes
      battle.pbDisplay(_INTL("{1} changed back to its regular type!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    else
      # Change to new typing
      terrain_hash = {
        :ElectricTerrain => :ELECTRIC,
        :GrassyTerrain   => :GRASS,
        :MistyTerrain    => :FAIRY,
        :PsychicTerrain  => :PSYCHIC,
		    :RockyField      => :ROCK,
		    :CorrosiveField	 => :POISON,
        :CorrosiveMistField	 => :POISON,
        :BurningField    => :FIRE,
        :DesertField    => :GROUND
      }
      new_type = terrain_hash[battle.field.terrain]
      new_type_name = nil
      if new_type
        type_data = GameData::Type.try_get(new_type)
        new_type = nil if !type_data
        new_type_name = type_data.name if type_data
      end
      if new_type
        battle.pbShowAbilitySplash(battler)
        battler.pbChangeTypes(new_type)
        battle.pbDisplay(_INTL("{1}'s type changed to {2}!", battler.pbThis, new_type_name))
        battle.pbHideAbilitySplash(battler)
      end
    end
  }
)

# Water Compaction
Battle::AbilityEffects::OnSwitchIn.add(:WATERCOMPACTION,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :None
    if [:CorrosiveMistField].include?(battle.field.terrain)
      battler.pbRaiseStatStageByAbility(:DEFENSE, 2, battler)
    end
  }
)

=begin
# Overgrow
Battle::AbilityEffects::DamageCalcFromUser.add(:OVERGROW,
  proc { |ability, user, target, move, mults, power, type|
    if (user.hp <= user.totalhp / 3 || user.battle.field.terrain == :GrassyTerrain) && type == :GRASS
      mults[:power_multiplier] *= 1.5
    end
  }
)

# Effect Spore
Battle::AbilityEffects::OnBeingHit.add(:EFFECTSPORE,
  proc { |ability, user, target, move, battle|
    # NOTE: This ability has a 30% chance of triggering, not a 30% chance of
    #       inflicting a status condition. It can try (and fail) to inflict a
    #       status condition that the user is immune to.
    next if !move.pbContactMove?(user)
	if battle.field.terrain == :GrassyTerrain
	   next if battle.pbRandom(100) >= 60
	else
	   next if battle.pbRandom(100) >= 30
	end 
    r = battle.pbRandom(3)
    next if r == 0 && user.asleep?
    next if r == 1 && user.poisoned?
    next if r == 2 && user.paralyzed?
    battle.pbShowAbilitySplash(target)
    if user.affectedByPowder?(Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      case r
      when 0
        if user.pbCanSleep?(target, Battle::Scene::USE_ABILITY_SPLASH)
          msg = nil
          if !Battle::Scene::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} made {3} fall asleep!", target.pbThis,
               target.abilityName, user.pbThis(true))
          end
          user.pbSleep(msg)
        end
      when 1
        if user.pbCanPoison?(target, Battle::Scene::USE_ABILITY_SPLASH)
          msg = nil
          if !Battle::Scene::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} poisoned {3}!", target.pbThis,
               target.abilityName, user.pbThis(true))
          end
          user.pbPoison(target, msg)
        end
      when 2
        if user.pbCanParalyze?(target, Battle::Scene::USE_ABILITY_SPLASH)
          msg = nil
          if !Battle::Scene::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
               target.pbThis, target.abilityName, user.pbThis(true))
          end
          user.pbParalyze(target, msg)
        end
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:SOLIDROCK,
  proc { |ability, user, target, move, mults, power, type|
    if Effectiveness.super_effective?(target.damageState.typeMod) || 
	   target.battle.field.terrain == :Unfine
      mults[:final_damage_multiplier] *= 0.75
    end
  }
)

Battle::AbilityEffects::EndOfRoundHealing.add(:WATERABSORB,
  proc { |ability, battler, battle|
    next if battle.field.terrain != :Unfine
	next if battler.airborne?
    next if !battler.canHeal?
    battler.pbRecoverHP(battler.totalhp / 16)
    battle.pbDisplay(_INTL("{1} restored a little HP!",battler.pbThis))
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:WATERCOMPACTION,
  proc { |ability, battler, battle|
    next if battle.field.terrain != :Unfine
	battler.pbRaiseStatStageByAbility(:DEFENSE, 2, battler) if battler.pbCanRaiseStatStage?(:DEFENSE, battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:KEENEYE,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain != :Unfine
    battler.pbRaiseStatStageByAbility(:EVASION, 1, battler)
  }
)
=end