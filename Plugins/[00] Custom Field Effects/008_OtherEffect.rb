#=============================================================================
# End Of Round Effect
#=============================================================================
class Battle
  def pbEORTerrainHealing(battler)
    return if battler.fainted?

#============================================================================= 01 Electric Terrain
    if [:ElectricTerrain].include?(@field.terrain)
      if battler.affectedByTerrain?

      end
    end
#============================================================================= 02 Grassy Terrain
    if [:GrassyTerrain].include?(@field.terrain)
      if battler.affectedByTerrain?
        if battler.canHeal?
          battler.pbRecoverHP(battler.totalhp / 16)
          pbDisplay(_INTL("{1}'s HP was restored by the grass.", battler.pbThis))
        end
      end
    end
#============================================================================= 03 Misty Terrain
    if [:MistyTerrain].include?(@field.terrain)
      if battler.affectedByTerrain?
        if battler.canHeal? && battler.hasActiveAbility?(:DRYSKIN) && ![:Sun, :HarshSun].include?(battler.effectiveWeather)
          pbShowAbilitySplash(battler)
          battler.pbRecoverHP(battler.totalhp / 16)
          pbDisplay(_INTL("{1}'s HP was restored by the mist.", battler.pbThis))
          pbHideAbilitySplash(battler)
        end
      end
	  end
#============================================================================= 06 Rocky Field
    if [:RockyField].include?(@field.terrain) 
		
	  end
#============================================================================= 08 Corrosive Mist Field
    if [:CorrosiveMistField].include?(@field.terrain)
      if battler.takesIndirectDamage? && battler.affectedByTerrain? && ![:POISON, :STEEL].include?(battler.types) && battler.pbCanPoison?(nil, false) && !battler.hasActiveAbility?(:NEUTRALIZINGGAS)
        battler.pbPoison(nil, _INTL("{1} was poisoned by the corrosive mist!", battler.pbThis))
      end
      if battler.hasActiveAbility?(:DRYSKIN)
        types = battler.pbTypes(true)
        return if types.include?(:STEEL)
        pbShowAbilitySplash(battler)
        if types.include?(:POISON)
          battler.pbRecoverHP(battler.totalhp / 8, true)
          pbDisplay(_INTL("{1}'s HP was restored by the mist.", battler.pbThis))
          pbHideAbilitySplash(battler)
        else
          battler.pbReduceHP(battler.totalhp / 8, true)
          pbDisplay(_INTL("{1} was hurt by the mist!", battler.pbThis))
          battler.pbItemHPHealCheck
          pbHideAbilitySplash(battler)
          battler.pbFaint if battler.fainted?
        end 
      end
    end

#=============================================================================
  end
end

#=============================================================================
# End Of Round Weather Effects
#=============================================================================
class Battle
  def pbEORWeatherDamage(battler)
    return if battler.fainted?
    amt = -1
    case battler.effectiveWeather
      when :Sandstorm
        return if !battler.takesSandstormDamage?
        pbDisplay(_INTL("{1} is buffeted by the sandstorm!", battler.pbThis))
        amt = battler.totalhp / 16
        amt = battler.totalhp / 8 if [:RockyField].include?(@field.terrain)
      when :Hail
        return if !battler.takesHailDamage?
        pbDisplay(_INTL("{1} is buffeted by the hail!", battler.pbThis))
        amt = battler.totalhp / 16
      when :ShadowSky
        return if !battler.takesShadowSkyDamage?
        pbDisplay(_INTL("{1} is hurt by the shadow sky!", battler.pbThis))
        amt = battler.totalhp / 16
      when :Rain
        if battler.battle.field.terrain == :BurningField
          battler.battle.pbStartTerrain(battler, :None, false) 
          pbDisplay(_INTL("The rain snuffed out the flames!"))
        end
    end
    return if amt < 0
    @scene.pbDamageAnimation(battler)
    battler.pbReduceHP(amt, false)
    battler.pbItemHPHealCheck
    battler.pbFaint if battler.fainted?
  end
end

#=============================================================================
# End Of Round Deal Damage To Trapped Battlers
#=============================================================================
class Battle
  TRAPPING_MOVE_COMMON_ANIMATIONS = {
    :BIND        => "Bind",
    :CLAMP       => "Clamp",
    :FIRESPIN    => "FireSpin",
    :MAGMASTORM  => "MagmaStorm",
    :SANDTOMB    => "SandTomb",
    :WRAP        => "Wrap",
    :INFESTATION => "Infestation"
  }
  def pbEORTrappingDamage(battler)
    return if battler.fainted? || battler.effects[PBEffects::Trapping] == 0
    battler.effects[PBEffects::Trapping] -= 1
    move_name = GameData::Move.get(battler.effects[PBEffects::TrappingMove]).name
    if battler.effects[PBEffects::Trapping] == 0
      pbDisplay(_INTL("{1} was freed from {2}!", battler.pbThis, move_name))
      return
    end
    anim = TRAPPING_MOVE_COMMON_ANIMATIONS[battler.effects[PBEffects::TrappingMove]] || "Wrap"
    pbCommonAnimation(anim, battler)
    return if !battler.takesIndirectDamage?
    hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? battler.totalhp / 8 : battler.totalhp / 16
    if @battlers[battler.effects[PBEffects::TrappingUser]].hasActiveItem?(:BINDINGBAND)
      hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? battler.totalhp / 6 : battler.totalhp / 8
    end
#============================================================================= 06
    if [:GrassyTerrain].include?(@field.terrain) && battler.affectedByTerrain? &&
       battler.effects[PBEffects::TrappingMove] == :SNAPTRAP
       hpLoss = battler.totalhp / 6
	  end
    if [:DesertField].include?(@field.terrain) && battler.affectedByTerrain? && battler.effects[PBEffects::TrappingMove] == :SANDTOMB
      hpLoss = battler.totalhp / 6
    end
#=============================================================================
    @scene.pbDamageAnimation(battler)
    battler.pbTakeEffectDamage(hpLoss, false) do |hp_lost|
      pbDisplay(_INTL("{1} is hurt by {2}!", battler.pbThis, move_name))
    end
  end
end

#=============================================================================
# End Of Round Various Trapping Effects
#=============================================================================
class Battle::Move::BindTarget < Battle::Move
  def pbEffectAgainstTarget(user, target)
    return if target.fainted? || target.damageState.substitute
    return if target.effects[PBEffects::Trapping] > 0
    # Set trapping effect duration and info
    if user.hasActiveItem?(:GRIPCLAW)
      target.effects[PBEffects::Trapping] = (Settings::MECHANICS_GENERATION >= 5) ? 8 : 6
    else
      target.effects[PBEffects::Trapping] = 5 + @battle.pbRandom(2)
    end
    target.effects[PBEffects::TrappingMove] = @id
    target.effects[PBEffects::TrappingUser] = user.index
    # Message
    msg = _INTL("{1} was trapped!", target.pbThis)
    case @id
    when :BIND
      msg = _INTL("{1} was squeezed by {2}!", target.pbThis, user.pbThis(true))
    when :CLAMP
      msg = _INTL("{1} clamped {2}!", user.pbThis, target.pbThis(true))
    when :FIRESPIN
      msg = _INTL("{1} was trapped in the fiery vortex!", target.pbThis)
    when :INFESTATION
      msg = _INTL("{1} has been afflicted with an infestation by {2}!", target.pbThis, user.pbThis(true))
    when :MAGMASTORM
      msg = _INTL("{1} became trapped by Magma Storm!", target.pbThis)
    when :SANDTOMB
      msg = _INTL("{1} became trapped by Sand Tomb!", target.pbThis)
    when :WHIRLPOOL
      msg = _INTL("{1} became trapped in the vortex!", target.pbThis)
    when :WRAP
      msg = _INTL("{1} was wrapped by {2}!", target.pbThis, user.pbThis(true))
    end
    @battle.pbDisplay(msg)
  end
end

#=============================================================================
# Entry Hazards
#=============================================================================
=begin
class Battle
  def pbEntryHazards(battler)
    battler_side = battler.pbOwnSide
    # Stealth Rock
    if battler_side.effects[PBEffects::StealthRock] && battler.takesIndirectDamage? &&
       GameData::Type.exists?(:ROCK) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
      bTypes = battler.pbTypes(true)
      eff = Effectiveness.calculate(:ROCK, *bTypes)
#=============================================================================
      if !Effectiveness.ineffective?(eff)
        battler.pbReduceHP(battler.totalhp * eff / 7, false) if [:RockyField].include?(@field.terrain)
		battler.pbReduceHP(battler.totalhp * eff / 8, false)
#=============================================================================
        pbDisplay(_INTL("Pointed stones dug into {1}!", battler.pbThis))
        battler.pbItemHPHealCheck
      end
    end
    # Spikes
    if battler_side.effects[PBEffects::Spikes] > 0 && battler.takesIndirectDamage? &&
       !battler.airborne? && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
      spikesDiv = [8, 6, 4][battler_side.effects[PBEffects::Spikes] - 1]
      battler.pbReduceHP(battler.totalhp / spikesDiv, false)
      pbDisplay(_INTL("{1} is hurt by the spikes!", battler.pbThis))
      battler.pbItemHPHealCheck
    end
    # Toxic Spikes
    if battler_side.effects[PBEffects::ToxicSpikes] > 0 && !battler.fainted? && !battler.airborne?
      if battler.pbHasType?(:POISON)
        battler_side.effects[PBEffects::ToxicSpikes] = 0 if
        pbDisplay(_INTL("{1} absorbed the poison spikes!", battler.pbThis))
      elsif battler.pbCanPoison?(nil, false) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
        if battler_side.effects[PBEffects::ToxicSpikes] == 2
          battler.pbPoison(nil, _INTL("{1} was badly poisoned by the poison spikes!", battler.pbThis), true)
        else
          battler.pbPoison(nil, _INTL("{1} was poisoned by the poison spikes!", battler.pbThis))
        end
      end
    end 
=end
	class Battle
  def pbEntryHazards(battler)
    battler_side = battler.pbOwnSide
	# Stealth Rock Overhaul
    if battler_side.effects[PBEffects::StealthRock] && battler.takesIndirectDamage? &&
        GameData::Type.exists?(:ROCK) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
        bTypes = battler.pbTypes(true)
        eff = Effectiveness.calculate(:ROCK, *bTypes)
#=============================================================================
      if battler.pbHasType?(:ROCK) || battler.pbHasType?(:GROUND) || battler.pbHasType?(:STEEL) || battler.pbHasType?(:FIGHTING)
        battler_side.effects[PBEffects::StealthRock] = false
        pbDisplay(_INTL("{1} crushed the rocks!", battler.pbThis))
      elsif !battler.pbHasType?(:ROCK)|| !battler.pbHasType?(:GROUND) || !battler.pbHasType?(:STEEL) || !battler.pbHasType?(:FIGHTING) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
        if battler_side.effects[PBEffects::StealthRock]
          if !Effectiveness.ineffective?(eff)
            battler.pbReduceHP(battler.totalhp * eff / 8, false) if [:RockyField].include?(@field.terrain)
            battler.pbReduceHP(battler.totalhp * eff / 14, false)
#=============================================================================
            pbDisplay(_INTL("Pointed stones dug into {1}!", battler.pbThis))
            battler.pbItemHPHealCheck
            battler.pbFaint if battler.fainted?
		      end
		    end
      end
    end
	# Spikes Tweaks
	if battler_side.effects[PBEffects::Spikes] > 0 && battler.takesIndirectDamage? &&
       !battler.airborne? && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
	   if battler.pbHasType?(:GROUND) || battler.pbHasType?(:GRASS)
	     battler_side.effects[PBEffects::Spikes] = 0
		 pbDisplay(_INTL("{1} absorbed the spikes!", battler.pbThis))
	   elsif !battler.pbHasType?(:GROUND)|| !battler.pbHasType?(:GRASS) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
	   spikesDiv = [8, 6, 4][battler_side.effects[PBEffects::Spikes] - 1]
       battler.pbReduceHP(battler.totalhp / spikesDiv, false)
       pbDisplay(_INTL("{1} is hurt by the spikes!", battler.pbThis))
       battler.pbItemHPHealCheck
       battler.pbFaint if battler.fainted?
	  end
	 end
    # Toxic Spikes
    if battler_side.effects[PBEffects::ToxicSpikes] > 0 && !battler.fainted? && !battler.airborne?
      if battler.pbHasType?(:POISON) || battler.pbHasType?(:STEEL)
        battler_side.effects[PBEffects::ToxicSpikes] = 0 if @field.terrain != :CorrosiveField
        pbDisplay(_INTL("{1} absorbed the poison spikes!", battler.pbThis))
      elsif battler.pbCanPoison?(nil, false) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
        if battler_side.effects[PBEffects::ToxicSpikes] == 2
          battler.pbPoison(nil, _INTL("{1} was badly poisoned by the poison spikes!", battler.pbThis), true)
        else
          battler.pbPoison(nil, _INTL("{1} was poisoned by the poison spikes!", battler.pbThis))
        end
      end
    end
    # Sticky Web
    if battler_side.effects[PBEffects::StickyWeb] && !battler.fainted? && !battler.airborne? &&
       !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
      pbDisplay(_INTL("{1} was caught in a sticky web!", battler.pbThis))
      if battler.pbCanLowerStatStage?(:SPEED)
        battler.pbLowerStatStage(:SPEED, 1, nil)
        battler.pbItemStatRestoreCheck
      end
    end
	# Corrosive Field Entry Damage
	if @field.terrain == :CorrosiveField && !battler.airborne? && battler.takesIndirectDamage? && GameData::Type.exists?(:POISON) && !battler.pbHasType?(:POISON) && !battler.pbHasType?(:STEEL)
		bTypes = battler.pbTypes(true)
		eff = Effectiveness.calculate(:POISON, *bTypes)
		battler.pbReduceHP(battler.totalhp * eff / 8, false)
    battler.pbItemHPHealCheck
    battler.pbFaint if battler.fainted?
		pbDisplay(_INTL("{1} is hurt by the corrosion!", battler.pbThis))
	end
	
  end
end

#=============================================================================
# End Of Round Various Healing Effects
#=============================================================================
class Battle 
 def pbEORHealingEffects(priority)
    # Aqua Ring
    priority.each do |battler|
      next if !battler.effects[PBEffects::AquaRing]
      next if !battler.canHeal? && ![:CorrosiveMistField].include?(battler.field.terrain)
      next if [:POISON, :STEEL].include?(battler.pbTypes(true)) && [:CorrosiveMistField].include?(battler.field.terrain)
#=============================================================================
      hpGain = battler.totalhp / 16
	    hpGain = battler.totalhp / 8 if [:MistyTerrain].include?(@field.terrain)
#=============================================================================
      if [:CorrosiveMistField].include?(battler.field.terrain)
        battler.pbReduceHP(hpGain, false)
        pbDisplay(_INTL("{1} was hurt by the corroded aqua ring!", battler.pbThis(true)))
        battler.pbItemHPHealCheck
        battler.pbFaint if battler.fainted?
      else
        battler.pbRecoverHP(hpGain)
        pbDisplay(_INTL("Aqua Ring restored {1}'s HP!", battler.pbThis(true)))
      end
    end
    # Ingrain
    priority.each do |battler|
      next if !battler.effects[PBEffects::Ingrain]
      next if !battler.canHeal?
#=============================================================================
	    hpGain = battler.totalhp / 16
      hpGain = battler.totalhp / 8 if [:GrassyTerrain].include?(@field.terrain)
#=============================================================================
      hpGain = (hpGain * 1.3).floor if battler.hasActiveItem?(:BIGROOT)
      if @field.terrain == :CorrosiveField
        next if battler.pbHasType?(:POISON)
        next if battler.pbHasType?(:STEEL)
        battler.pbReduceHP(hpGain)
        pbDisplay(_INTL("{1} absorbed the toxins with its roots!", battler.pbThis))
      else
        battler.pbRecoverHP(hpGain)
        pbDisplay(_INTL("{1} absorbed nutrients with its roots!", battler.pbThis))
	    end
    end
    # Leech Seed
    priority.each do |battler|
      next if battler.effects[PBEffects::LeechSeed] < 0
      next if !battler.takesIndirectDamage?
      recipient = @battlers[battler.effects[PBEffects::LeechSeed]]
      next if !recipient || recipient.fainted?
      pbCommonAnimation("LeechSeed", recipient, battler)
      battler.pbTakeEffectDamage(battler.totalhp / 8) do |hp_lost|
        recipient.pbRecoverHPFromDrain(hp_lost, battler,
                                       _INTL("{1}'s health is sapped by Leech Seed!", battler.pbThis))
        recipient.pbAbilitiesOnDamageTaken
      end
      recipient.pbFaint if recipient.fainted?
    end
  end
end

#=============================================================================
# Switch Block
#=============================================================================
class Battle
  # Check whether the currently active Pokémon (at battler index idxBattler) can
  # switch out.
  def pbCanSwitchOut?(idxBattler, partyScene = nil)
    battler = @battlers[idxBattler]
    return true if battler.fainted?
    # Ability/item effects that allow switching no matter what
    if battler.abilityActive? && Battle::AbilityEffects.triggerCertainSwitching(battler.ability, battler, self)
      return true
    end
    if battler.itemActive? && Battle::ItemEffects.triggerCertainSwitching(battler.item, battler, self)
      return true
    end
    # Other certain switching effects
    return true if Settings::MORE_TYPE_EFFECTS && battler.pbHasType?(:GHOST)
    # Other certain trapping effects
    if battler.trappedInBattle?
      partyScene&.pbDisplay(_INTL("{1} can't be switched out!", battler.pbThis))
      return false
    end
#=============================================================================
=begin
	if [:ElectricTerrain].include?(@field.terrain) &&
	   !battler.isSpecies?(:PIKACHU)
	partyScene&.pbDisplay(_INTL("{1} can't be switched out!", battler.pbThis))
	return false
	end
=end
#=============================================================================
    # Trapping abilities/items
    allOtherSideBattlers(idxBattler).each do |b|
      next if !b.abilityActive?
      if Battle::AbilityEffects.triggerTrappingByTarget(b.ability, battler, b, self)
        partyScene&.pbDisplay(_INTL("{1}'s {2} prevents switching!", b.pbThis, b.abilityName))
        return false
      end
    end
    allOtherSideBattlers(idxBattler).each do |b|
      next if !b.itemActive?
      if Battle::ItemEffects.triggerTrappingByTarget(b.item, battler, b, self)
        partyScene&.pbDisplay(_INTL("{1}'s {2} prevents switching!", b.pbThis, b.itemName))
        return false
      end
    end
    return true
  end
end

#=============================================================================
# Grounded
#=============================================================================
class Battle::Battler
	def airborne?
		return false if hasActiveItem?(:IRONBALL)
		return false if @effects[PBEffects::Ingrain]
		return false if @effects[PBEffects::SmackDown]
		return false if @battle.field.effects[PBEffects::Gravity] > 0
#=============================================================================	
    #return false if [:ElectricTerrain].include?(@battle.field.terrain)
#=============================================================================	
		return true if pbHasType?(:FLYING)
		return true if hasActiveAbility?(:LEVITATE) && !@battle.moldBreaker
		return true if hasActiveItem?(:AIRBALLOON)
		return true if @effects[PBEffects::MagnetRise] > 0
		return true if @effects[PBEffects::Telekinesis] > 0
		return false
	end
	
    def pbCanSleep?(user, showMessages, move = nil, ignoreStatus = false)
		return false if affectedByTerrain? && [:ElectricTerrain, :MistyTerrain].include?(@battle.field.terrain)
		return pbCanInflictStatus?(:SLEEP, user, showMessages, move, ignoreStatus)
    end
  
	def pbCanSleepYawn?
		return false if self.status != :NONE
		if affectedByTerrain? && [:ElectricTerrain, :MistyTerrain].include?(@battle.field.terrain)
		  return false
		end
		if !hasActiveAbility?(:SOUNDPROOF) && @battle.allBattlers.any? { |b| b.effects[PBEffects::Uproar] > 0 }
		  return false
		end
		if Battle::AbilityEffects.triggerStatusImmunityNonIgnorable(self.ability, self, :SLEEP)
		  return false
		end
		# NOTE: Bulbapedia claims that Flower Veil shouldn't prevent sleep due to
		#       drowsiness, but I disagree because that makes no sense. Also, the
		#       comparable Sweet Veil does prevent sleep due to drowsiness.
		if abilityActive? && Battle::AbilityEffects.triggerStatusImmunity(self.ability, self, :SLEEP)
		  return false
		end
		allAllies.each do |b|
		  next if !b.abilityActive?
		  next if !Battle::AbilityEffects.triggerStatusImmunityFromAlly(b.ability, self, :SLEEP)
		  return false
		end
		# NOTE: Bulbapedia claims that Safeguard shouldn't prevent sleep due to
		#       drowsiness. I disagree with this too. Compare with the other sided
		#       effects Misty/Electric Terrain, which do prevent it.
		return false if pbOwnSide.effects[PBEffects::Safeguard] > 0
		return true
	end
  
end

#=============================================================================
# Weather Calculation
#=============================================================================
class Battle
  def pbWeather
    return :None if allBattlers.any? { |b| b.hasActiveAbility?([:CLOUDNINE, :AIRLOCK]) }
	#return :None if [:GrassyField].include?(@field.terrain)
    return @field.weather
  end
end