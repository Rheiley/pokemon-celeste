#===============================================================================
# Move Effect
#===============================================================================
class Battle::Battler

  def pbCanFreeze?(user, showMessages, move = nil)
    return false if user.battle.field.terrain == :BurningField
    return pbCanInflictStatus?(:FROZEN, user, showMessages, move)
  end

  alias fieldEffects_pbEffectsAfterMove pbEffectsAfterMove
  def pbEffectsAfterMove(user, targets, move, numHits)
#============================================================================= 01 Electric Terrain
    if ![:ElectricTerrain].include?(@battle.field.terrain)
      if [:STOKEDSPARKSURFER, :IONDELUGE, :PLASMAFISTS].include?(move.id)
        @battle.pbStartTerrain(user, :ElectricTerrain)
      end
    end
    if [:ElectricTerrain].include?(@battle.field.terrain) 
      # if [:TECTONICRAGE, :SPLINTEREDSTORMSHARDS].include?(move.id)
      #   @battle.pbDisplay(_INTL("The hyper-charged terrain shorted out!"))
      #   @battle.pbStartTerrain(user, :None, false)
      # end
    end
#============================================================================= 02 Grassy Terrain
    if ![:GrassyTerrain].include?(@battle.field.terrain)
      if [:BLOOMDOOM].include?(move.id)
        @battle.pbStartTerrain(user, :GrassyTerrain) # Set Grassy Terrain for 5 turns
      end
    end
    if [:GrassyTerrain].include?(@battle.field.terrain) 
      if [:SLUDGEWAVE, :ACIDDOWNPOUR].include?(move.id)
        @battle.pbDisplay(_INTL("The grassy terrain was corroded!"))
        @battle.pbStartTerrain(user, :CorrosiveField, false)
      end
      if [:ERUPTION, :FIREPLEDGE, :FLAMEBURST, :HEATWAVE, :INCINERATE, :LAVAPLUME, :MINDBLOWN, :SEARINGSHOT, :INFERNOOVERDRIVE].include?(move.id) && 
         ![:Rain, :HeavyRain].include?(user.effectiveWeather) && @battle.field.effects[PBEffects::WaterSportField] == 0
        @battle.pbDisplay(_INTL("The grass was burned away!"))
        @battle.pbStartTerrain(user, :BurningField, false)
      end
    end
#============================================================================= 03 Misty Terrain
    if ![:MistyTerrain].include?(@battle.field.terrain)
      if [:MIST].include?(move.id)
        @battle.pbStartTerrain(user, :MistyTerrain)
      end
    end 
    if [:MistyTerrain].include?(@battle.field.terrain)
      if user.affectedByTerrain?
        if [:SWEETSCENT].include?(move.id) 
          targets.each do |b|
            next if !b.pbCanLowerStatStage?(:DEFENSE, user, self) && !b.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user, self) 
            b.pbLowerStatStage(:DEFENSE, 1, user)
            b.pbLowerStatStage(:SPECIAL_DEFENSE, 1, user, false)
          end
        end
        if [:AROMATICMIST].include?(move.id) 
          targets.each do |b|
            next if !b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user, self)
            b.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, user)
          end
        end
        if [:WHIRLWIND, :GUST, :RAZORWIND, :HURRICANE, :DEFOG, :TAILWIND, :TWISTER, :SUPERSONICSKYSTRIKE].include?(move.id)
          @battle.pbDisplay(_INTL("The mist was blown away!"))
          @battle.pbStartTerrain(user, :None, false)
        end
        if [:CLEARSMOG, :SMOG, :POISONGAS, :ACIDDOWNPOUR].include?(move.id)
          @battle.pbDisplay(_INTL("The mist was corroded!"))
          @battle.pbStartTerrain(user, :CorrosiveMistField, false)
        end
      end
    end
#============================================================================= 04 Psychic Terrain
    if ![:PsychicTerrain].include?(@battle.field.terrain)
      if [:PSYWAVE].include?(move.id)
        @battle.pbStartTerrain(user, :PsychicTerrain)
      end
    end
    if [:PsychicTerrain].include?(@battle.field.terrain)
      if user.affectedByTerrain?
        if [:CRUNCH].include?(move.id)
          @battle.pbDisplay(_INTL("The weirdness is gone!"))
          @battle.pbStartTerrain(user, :None, false)
        end
      end
    end
#============================================================================= 05 Inverse Field
    if ![:InverseField].include?(@battle.field.terrain)
      if [:WONDERROOM, :TOPSYTURVY].include?(move.id)
        @battle.pbStartTerrain(user, :InverseField)
      end
    end
    if [:InverseField].include?(@battle.field.terrain) 
      if user.affectedByTerrain?
        if[:TOPSYTURVY].include?(move.id)
          @battle.pbDisplay(_INTL("!dne elttaB"))
          @battle.pbStartTerrain(user, :None, false)
        end
      end
    end
#============================================================================= 06 Rocky Field
    if [:RockyField].include?(@battle.field.terrain)

    end
#============================================================================= 07 Corrosive Field
    if [:CorrosiveField].include?(@battle.field.terrain)
      if [:SEEDFLARE, :PURIFY].include?(move.id)
        @battle.pbDisplay(_INTL("The polluted field was purified!"))
        @battle.pbStartTerrain(user, :GrassyTerrain)
      end
    end
#============================================================================= 08 Corrosive Mist Field
    if [:CorrosiveMistField].include?(@battle.field.terrain)
      if [:GRAVITY].include?(move.id)
        @battle.pbDisplay(_INTL("The toxic mist collected on the ground!"))
        @battle.pbStartTerrain(user, :CorrosiveField, false)
      end
      if [:SEEDFLARE].include?(move.id)
        @battle.pbDisplay(_INTL("The polluted mist was purified!"))
        @battle.pbStartTerrain(user, :MistyTerrain, false)
      end
      if [:DEFOG, :GUST, :HURRICANE, :RAZORWIND, :SUPERSONICSKYSTRIKE, :TAILWIND, :TWISTER, :WHIRLWIND].include?(move.id)
        @battle.pbDisplay(_INTL("The mist was blown away!"))
        @battle.pbStartTerrain(user, :None, false)
      end
      if [:FLAMEBURST, :ERUPTION, :EXPLOSION, :FIREPLEDGE, :HEATWAVE, :INCINERATE, :INFERNOOVERDRIVE, :LAVAPLUME, :MINDBLOWN, :SEARINGSHOT, :SELFDESTRUCT].include?(move.id)
        damp = false
        @battle.allBattlers.each do |battler|
          if battler.hasActiveAbility?(:DAMP)
            damp = true
            @battle.pbShowAbilitySplash(battler)
            @battle.pbDisplay(_INTL("The dampness prevented the combustion!"))
            @battle.pbHideAbilitySplash(battler)
          end
        end
        if !damp
          @battle.pbStartTerrain(user, :None, false)
          @battle.pbDisplay(_INTL("The toxic mist combusted!"))
          @battle.allBattlers.each do |battler|
            next if battler.effects[PBEffects::Protect]|| battler.effects[PBEffects::BanefulBunker] || battler.effects[PBEffects::WideGuard] || 
                    battler.hasActiveAbility?(:FLASHFIRE) || !battler.affectedByTerrain?
            if battler.hasActiveAbility?(:STURDY) || battler.effects[PBEffects::Endure]
              amt = battler.totalhp - 1 if battler.hasActiveAbility?(:STURDY)
              amt = battler.hp - 1 if battler.effects[PBEffects::Endure]
              battler.pbReduceHP(amt, false) 
              @battle.pbShowAbilitySplash(battler)
              @battle.pbDisplay(_INTL("{1} hung on with Sturdy!", battler.pbThis)) if battler.hasActiveAbility?(:STURDY)
              @battle.pbDisplay(_INTL("{1} endured the combustion!", battler.pbThis)) if battler.effects[PBEffects::Endure]
              @battle.pbHideAbilitySplash(battler)
            else
              battler.pbReduceHP(battler.totalhp, false)
            end
            battler.pbFaint if battler.fainted?
          end
        end
      end
    end
#============================================================================= 09 Burning Field
    if [:BurningField].include?(@battle.field.terrain)
      if [:MUDDYWATER, :SPARKLINGARIA, :SURF, :WATERPLEDGE, :WATERSPORT, :WATERSPOUT, :CONTINENTALCRUSH, :HYDROVORTEX, :OCEANICOPERETTA].include?(move.id)
        @battle.pbStartTerrain(user, :None, false)
      end
    end
#=============================================================================
=begin
	@battle.pbDisplay(_INTL("The current is gone!"))
	if ![:Rain, :HeavyRain].include?(user.effectiveWeather) && 
		[:THUNDERWAVE].include?(move.id)
	@battle.pbDisplay(_INTL("The mist is gone!"))
	@battle.pbStartTerrain(user, :PsychicTerrain)
	end
	if [:DISCHARGE].include?(move.id)
	@battle.pbDisplay(_INTL("The current is gone!"))
          targets.each do |b|
	next if b.damageState.unaffected || b.damageState.substitute || ![:SLEEP, :DROWSY].include?(b.status)
		 next if b.fainted? || b.damageState.unaffected
		b.pbLowerStatStage(:SPECIAL_ATTACK, 2, user)
	  end
	end
	#@battle.field.terrainDuration = 1
=end
#=============================================================================
    @battle.scene.pbSetFieldBackground
    fieldEffects_pbEffectsAfterMove(user, targets, move, numHits)
  end
end

#===============================================================================
# Move Affected
#=============================================================================== 

# Acid Armor
class Battle::Move::RaiseUserDefense2 < Battle::Move::StatUpMove
  def initialize(battle, move)
    super
    if [:ACIDARMOR].include?(@id) && [:CorrosiveField, :CorrosiveMistField].include?(battle.field.terrain)
      @statUp = [:DEFENSE, 3]
    else
      @statUp = [:DEFENSE, 2]
    end
  end
end

# Rock Polish
class Battle::Move::RaiseUserSpeed2 < Battle::Move::StatUpMove
  def initialize(battle, move)
    super
    if [:ROCKPOLISH].include?(@id) && [:RockyField].include?(battle.field.terrain)
      @statUp = [:SPEED, 3]
    else
      @statUp = [:SPEED, 2]
    end
  end
end

# Electric Terrain
class Battle::Move::StartElectricTerrain < Battle::Move
  def pbMoveFailed?(user, targets)
	if ![:None, :GrassyTerrain, :MistyTerrain, :PsychicTerrain].include?(@battle.field.terrain)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :ElectricTerrain)    
  end
end

# Rising Voltage
class Battle::Move::DoublePowerInElectricTerrain < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if [:ElectricTerrain].include?(@battle.field.terrain) && target.affectedByTerrain?
    return baseDmg
  end
end

# Plasma Fists/ Ion Deluge
class Battle::Move::NormalMovesBecomeElectric < Battle::Move
  def pbMoveFailed?(user, targets)
    return false if damagingMove?
    if @battle.field.effects[PBEffects::IonDeluge]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedLastInRound?(user)
    return false
  end

  def pbEffectGeneral(user)
    return if @battle.field.effects[PBEffects::IonDeluge]
    @battle.field.effects[PBEffects::IonDeluge] = true
    @battle.pbDisplay(_INTL("A deluge of ions showers the battlefield!"))
  end
end

# Magnet Rise
class Battle::Move::StartUserAirborne < Battle::Move
  def unusableInGravity?; return true; end
  def canSnatch?;         return true; end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Ingrain] ||
       user.effects[PBEffects::SmackDown] ||
       user.effects[PBEffects::MagnetRise] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::MagnetRise] = 5
    user.effects[PBEffects::MagnetRise] = 8 if [:ElectricTerrain].include?(@battle.field.terrain)
    @battle.pbDisplay(_INTL("{1} levitated with electromagnetism!", user.pbThis))
  end
end

# Focus Punch
class Battle::Move::FailsIfUserDamagedThisTurn < Battle::Move
  def pbDisplayChargeMessage(user)
    user.effects[PBEffects::FocusPunch] = true
    @battle.pbCommonAnimation("FocusPunch", user)
    @battle.pbDisplay(_INTL("{1} is tightening its focus!", user.pbThis))
  end

  def pbDisplayUseMessage(user)
    super if !user.effects[PBEffects::FocusPunch] || !user.tookMoveDamageThisRound
  end

  def pbMoveFailed?(user, targets)
    if (user.effects[PBEffects::FocusPunch] && user.tookMoveDamageThisRound) ||
	   [:ElectricTerrain].include?(@battle.field.terrain)
       @battle.pbDisplay(_INTL("{1} lost its focus and couldn't move!", user.pbThis))
       return true
    end
    return false
  end
end

#Charge
class Battle::Move::RaiseUserSpDef1PowerUpElectricMove < Battle::Move::StatUpMove
  def initialize(battle, move)
    super
    if [:ElectricTerrain].include?(battle.field.terrain)
      @statUp = [:SPECIAL_DEFENSE, 2]
    else
      @statUp = [:SPECIAL_DEFENSE, 1]
    end
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Charge] = 2
    @battle.pbDisplay(_INTL("{1} began charging power!", user.pbThis))
    super
  end
end

# Eerie Impulse
class Battle::Move::LowerTargetSpAtk2 < Battle::Move::TargetStatDownMove
  def initialize(battle, move)
    super
	@statDown = [:SPECIAL_ATTACK, 2]
  end
end

#=============================================================================== 02/06
# Grassy Terrain
class Battle::Move::StartGrassyTerrain < Battle::Move
  def pbMoveFailed?(user, targets)
	if ![:None, :ElectricTerrain, :MistyTerrain, :PsychicTerrain].include?(@battle.field.terrain)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :GrassyTerrain)
  end
end

# Floral Healing
class Battle::Move::HealTargetDependingOnGrassyTerrain < Battle::Move
  def healingMove?;  return true; end
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.hp == target.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", target.pbThis)) if show_message
      return true
    elsif !target.canHeal?
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    if [:GrassyTerrain].include?(@battle.field.terrain)
	   hpGain = (target.totalhp * 2 / 3.0).round
	   @battle.pbDisplay(_INTL("Green grass enhanced the healing effect!"))
       target.pbRecoverHP(hpGain)	   
    else 
       hpGain = (target.totalhp / 2.0).round
       target.pbRecoverHP(hpGain)
	  end
	  target.pbPoison(nil, _INTL("{1} was poisoned by the poisonous flowers!", target.pbThis), true) if [:CorrosiveField, :CorrosiveMistField].include?(@battle.field.terrain) && !target.poisoned?
    @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
  end
end

# Life Dew
class Battle::Move::HealUserAndAlliesQuarterOfTotalHP < Battle::Move
  def healingMove?; return true; end

  def pbMoveFailed?(user, targets)
    if @battle.allSameSideBattlers(user).none? { |b| b.canHeal? }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return !target.canHeal?
  end

  def pbEffectAgainstTarget(user, target)
    target.pbPoison(nil, _INTL("{1} was poisoned by the toxic water!", target.pbThis), true) if [:CorrosiveField, :CorrosiveMistField].include?(@battle.field.terrain) && !target.poisoned?
    target.pbRecoverHP(target.totalhp / 4)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
  end
end

# Grassy Glide
class Battle::Move::HigherPriorityInGrassyTerrain < Battle::Move
  def pbPriority(user)
    ret = super
	  ret += 1 if [:GrassyTerrain].include?(@battle.field.terrain) && user.affectedByTerrain?
    return ret
  end
end

# Earthquake
class Battle::Move::DoublePowerIfTargetUnderground < Battle::Move
  def hitsDiggingTargets?; return true; end

  def pbModifyDamage(damageMult, user, target)
    damageMult *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
    damageMult /= 2 if [:GrassyTerrain].include?(@battle.field.terrain)
    return damageMult
  end
end

# Magnitude
class Battle::Move::RandomPowerDoublePowerIfTargetUnderground < Battle::Move
  def hitsDiggingTargets?; return true; end

  def pbOnStartUse(user, targets)
    baseDmg = [10, 30, 50, 70, 90, 110, 150]
    magnitudes = [
      4,
      5, 5,
      6, 6, 6, 6,
      7, 7, 7, 7, 7, 7,
      8, 8, 8, 8,
      9, 9,
      10
    ]
    magni = magnitudes[@battle.pbRandom(magnitudes.length)]
    @magnitudeDmg = baseDmg[magni - 4]
    @battle.pbDisplay(_INTL("Magnitude {1}!", magni))
  end

  def pbBaseDamage(baseDmg, user, target)
    return @magnitudeDmg
  end

  def pbModifyDamage(damageMult, user, target)
    damageMult *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
    damageMult /= 2 if [:GrassyTerrain].include?(@battle.field.terrain)
    return damageMult
  end
end

# Bulldoze
class Battle::Move::LowerTargetSpeed1WeakerInGrassyTerrain < Battle::Move::TargetStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:SPEED, 1]
  end

  def pbBaseDamage(baseDmg, user, target)
    baseDmg = (baseDmg / 2.0).round if [:GrassyTerrain].include?(@battle.field.terrain)
    return baseDmg
  end
end

# Nature's Madness / Super Fang
class Battle::Move::FixedDamageHalfTargetHP < Battle::Move::FixedDamageMove
  def pbFixedDamage(user, target)
    return (target.hp * 3.0 / 4.0).round if [:NATURESMADNESS].include?(@id) && [:GrassyTerrain].include?(user.battle.field.terrain)
    return (target.hp / 2.0).round
  end
end

# Growth
class Battle::Move::RaiseUserAtkSpAtk1Or2InSun < Battle::Move::MultiStatUpMove
  def initialize(battle, move)
    super
    @statUp = [:ATTACK, 1, :SPECIAL_ATTACK, 1]
  end

  def pbOnStartUse(user, targets)
    increment = 1
    increment = 2 if [:Sun, :HarshSun].include?(user.effectiveWeather)
    @statUp[1] = @statUp[3] = increment
  end
end

# Coil
class Battle::Move::RaiseUserAtkDefAcc1 < Battle::Move::MultiStatUpMove
  def initialize(battle, move)
    super
    if ![:Sun, :HarshSun].include?(user.effectiveWeather)
      @statUp = [:ATTACK, 2, :DEFENSE, 2, :ACCURACY, 2]
    else
      @statUp = [:ATTACK, 1, :DEFENSE, 1, :ACCURACY, 1]
    end
  end
end

# Ingrain
class Battle::Move::StartHealUserEachTurnTrapUserInBattle < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Ingrain] = true
    @battle.pbDisplay(_INTL("{1} planted its roots!", user.pbThis))
  end
end

# Misty Terrain
class Battle::Move::StartMistyTerrain < Battle::Move
  def pbMoveFailed?(user, targets)
	if ![:None, :ElectricTerrain, :GrassyTerrain, :PsychicTerrain].include?(@battle.field.terrain)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :MistyTerrain)
  end
end

# Misty Explosion
class Battle::Move::UserFaintsPowersUpInMistyTerrainExplosive < Battle::Move::UserFaintsExplosive
  def pbBaseDamage(baseDmg, user, target)
    baseDmg = baseDmg * 3 / 2 if [:MistyTerrain].include?(@battle.field.terrain) && user.affectedByTerrain? 
    return baseDmg
  end
end

# Sweet Scent
class Battle::Move::LowerTargetEvasion2 < Battle::Move::TargetStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:EVASION, 2]
  end
end

# Wish
class Battle::Move::HealUserPositionNextTurn < Battle::Move
  def healingMove?; return true; end
  def canSnatch?;   return true; end

  def pbMoveFailed?(user, targets)
    if @battle.positions[user.index].effects[PBEffects::Wish] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.positions[user.index].effects[PBEffects::Wish]       = 2
	if [:MistyTerrain].include?(@battle.field.terrain)
    @battle.positions[user.index].effects[PBEffects::WishAmount] = (user.totalhp * 3 / 4.0).round
	# @battle.pbDisplay(_INTL("The mist enhanced the healing effect."))
	else
	@battle.positions[user.index].effects[PBEffects::WishAmount] = (user.totalhp / 2.0).round
	end
    @battle.positions[user.index].effects[PBEffects::WishMaker]  = user.pokemonIndex
  end
end

# Healing Wish
class Battle::Move::UserFaintsHealAndCureReplacement < Battle::Move
  def healingMove?; return true; end
  def canSnatch?;   return true; end

  def pbMoveFailed?(user, targets)
    if !@battle.pbCanChooseNonActive?(user.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp, false)
    user.pbItemHPHealCheck
    @battle.positions[user.index].effects[PBEffects::HealingWish] = true
  end
end

# Explosion / Self-Destruct
class Battle::Move::UserFaintsExplosive < Battle::Move
  def worksWithNoTargets?;      return true; end
  def pbNumHits(user, targets); return 1;    end

  def pbMoveFailed?(user, targets)
    if !@battle.moldBreaker
      bearer = @battle.pbCheckGlobalAbility(:DAMP)
      if bearer
        @battle.pbShowAbilitySplash(bearer)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} cannot use {2}!", user.pbThis, @name))
        else
          @battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
                                  user.pbThis, @name, bearer.pbThis(true), bearer.abilityName))
        end
        @battle.pbHideAbilitySplash(bearer)
        return true
      end
    end
	if [:MistyTerrain].include?(@battle.field.terrain)
	@battle.pbDisplay(_INTL("The damp mist prevented the explosion..."))
	return true
	end
    return false
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp, false)
    user.pbItemHPHealCheck
  end
end

# Psychic Terrain
class Battle::Move::StartPsychicTerrain < Battle::Move
  def pbMoveFailed?(user, targets)
	if ![:None, :ElectricTerrain, :GrassyTerrain, :MistyTerrain].include?(@battle.field.terrain)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :PsychicTerrain)
  end
end

# Expanding Force
class Battle::Move::HitsAllFoesAndPowersUpInPsychicTerrain < Battle::Move
  def pbTarget(user)
    if [:PsychicTerrain].include?(@battle.field.terrain) && user.affectedByTerrain?
      return GameData::Target.get(:AllNearFoes)
    end
    return super
  end

  def pbBaseDamage(baseDmg, user, target)
    if [:PsychicTerrain].include?(@battle.field.terrain) && user.affectedByTerrain?
      baseDmg = baseDmg * 3 / 2
    end
    return baseDmg
  end
end

#=============================================================================== All Terrain
# Steel Roller
class Battle::Move::RemoveTerrain < Battle::Move

  def pbMoveFailed?(user, targets)
    if ![:ElectricTerrain, :GrassyTerrain, :MistyTerrain, :PsychicTerrain].include?(@battle.field.terrain)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end 

  def pbEffectGeneral(user)
    case @battle.field.terrain
    when :ElectricTerrain
      @battle.pbDisplay(_INTL("The electricity disappeared from the battlefield."))
    when :GrassyTerrain
      @battle.pbDisplay(_INTL("The grass disappeared from the battlefield."))
    when :MistyTerrain
      @battle.pbDisplay(_INTL("The mist disappeared from the battlefield."))
    when :PsychicTerrain
      @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield."))
    end
    @battle.field.terrain = :None
  end 
end

# Defog
class Battle::Move::LowerTargetEvasion1RemoveSideEffects < Battle::Move::TargetStatDownMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle, move)
    super
    @statDown = [:EVASION, 1]
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    targetSide = target.pbOwnSide
    targetOpposingSide = target.pbOpposingSide
    return false if targetSide.effects[PBEffects::AuroraVeil] > 0 ||
                    targetSide.effects[PBEffects::LightScreen] > 0 ||
                    targetSide.effects[PBEffects::Reflect] > 0 ||
                    targetSide.effects[PBEffects::Mist] > 0 ||
                    targetSide.effects[PBEffects::Safeguard] > 0
    return false if targetSide.effects[PBEffects::StealthRock] ||
                    targetSide.effects[PBEffects::Spikes] > 0 ||
                    targetSide.effects[PBEffects::ToxicSpikes] > 0 ||
                    targetSide.effects[PBEffects::StickyWeb]
    return false if Settings::MECHANICS_GENERATION >= 6 &&
                    (targetOpposingSide.effects[PBEffects::StealthRock] ||
                    targetOpposingSide.effects[PBEffects::Spikes] > 0 ||
                    targetOpposingSide.effects[PBEffects::ToxicSpikes] > 0 ||
                    targetOpposingSide.effects[PBEffects::StickyWeb])
    return false if Settings::MECHANICS_GENERATION >= 8 && @battle.field.terrain != :None
    return super
  end

  def pbEffectAgainstTarget(user, target)
    if target.pbCanLowerStatStage?(@statDown[0], user, self)
      target.pbLowerStatStage(@statDown[0], @statDown[1], user)
    end
    if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
      target.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
      @battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!", target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::LightScreen] > 0
      target.pbOwnSide.effects[PBEffects::LightScreen] = 0
      @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!", target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Reflect] > 0
      target.pbOwnSide.effects[PBEffects::Reflect] = 0
      @battle.pbDisplay(_INTL("{1}'s Reflect wore off!", target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Mist] > 0
      target.pbOwnSide.effects[PBEffects::Mist] = 0
      @battle.pbDisplay(_INTL("{1}'s Mist faded!", target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Safeguard] > 0
      target.pbOwnSide.effects[PBEffects::Safeguard] = 0
      @battle.pbDisplay(_INTL("{1} is no longer protected by Safeguard!!", target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::StealthRock] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::StealthRock])
      target.pbOwnSide.effects[PBEffects::StealthRock]      = false
      target.pbOpposingSide.effects[PBEffects::StealthRock] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!", user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::Spikes] > 0 ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::Spikes] > 0)
      target.pbOwnSide.effects[PBEffects::Spikes]      = 0
      target.pbOpposingSide.effects[PBEffects::Spikes] = 0 if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away spikes!", user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0 ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::ToxicSpikes] > 0)
      target.pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
      target.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0 if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away poison spikes!", user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::StickyWeb] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::StickyWeb])
      target.pbOwnSide.effects[PBEffects::StickyWeb]      = false
      target.pbOpposingSide.effects[PBEffects::StickyWeb] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away sticky webs!", user.pbThis))
    end
	
    if Settings::MECHANICS_GENERATION >= 8 &&
	[:ElectricTerrain, :GrassyTerrain, :MistyTerrain, :PsychicTerrain].include?(@battle.field.terrain) # @battle.field.terrain != :None
      case @battle.field.terrain
      when :ElectricTerrain
        @battle.pbDisplay(_INTL("The electricity disappeared from the battlefield."))
      when :GrassyTerrain
        @battle.pbDisplay(_INTL("The grass disappeared from the battlefield."))
      when :MistyTerrain
        @battle.pbDisplay(_INTL("The mist disappeared from the battlefield."))
      when :PsychicTerrain
        @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield."))
      end
      @battle.field.terrain = :None
	  @battle.allBattlers.each { |b| b.pbAbilityOnTerrainChange }
    end
  end
end

# Terrain Pulse
class Battle::Move::TypeAndPowerDependOnTerrain < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if [:ElectricTerrain, :GrassyTerrain, :MistyTerrain, :PsychicTerrain, 
                    :InverseField, :RockyField, :CorrosiveField, :CorrosiveMistField, :BurningField].include?(@battle.field.terrain) && user.affectedByTerrain?
    return baseDmg
  end

  def pbBaseType(user)
    ret = :NORMAL
    case @battle.field.terrain
      when :ElectricTerrain
        ret = :ELECTRIC      if GameData::Type.exists?(:ELECTRIC)
      when :GrassyTerrain
        ret = :GRASS         if GameData::Type.exists?(:GRASS)
      when :MistyTerrain
        ret = :FAIRY         if GameData::Type.exists?(:FAIRY)
      when :PsychicTerrain
        ret = :PSYCHIC       if GameData::Type.exists?(:PSYCHIC)
      when :InverseField
        ret = :NORMAL        if GameData::Type.exists?(:NORMAL)
      when :RockyField
        ret = :ROCK          if GameData::Type.exists?(:ROCK)
      when :CorrosiveField 
        ret = :POISON        if GameData::Type.exists?(:POISON)
      when :CorrosiveMistField
        ret = :POISON        if GameData::Type.exists?(:POISON)
      when :BurningField
        ret = :FIRE          if GameData::Type.exists?(:FIRE)
      when :DesertField
        ret = :GROUND        if GameData::Type.exists?(:GROUND)
    end
    return ret
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    t = pbBaseType(user)
    hitNum = 1 if t == :ELECTRIC   # Type-specific anims
    hitNum = 2 if t == :GRASS
    hitNum = 3 if t == :FAIRY
    hitNum = 4 if t == :PSYCHIC
    super
  end
end

# Nature Power
class Battle::Move::UseMoveDependingOnEnvironment < Battle::Move
  attr_reader :npMove

  def callsAnotherMove?; return true; end

  def pbOnStartUse(user, targets)
    # NOTE: It's possible in theory to not have the move Nature Power wants to
    #       turn into, but what self-respecting game wouldn't at least have Tri
    #       Attack in it?
    @npMove = :TRIATTACK
    case @battle.field.terrain
      when :ElectricTerrain
        @npMove = :THUNDERBOLT   if GameData::Move.exists?(:THUNDERBOLT)
      when :GrassyTerrain
        @npMove = :ENERGYBALL    if GameData::Move.exists?(:ENERGYBALL)
      when :MistyTerrain
        @npMove = :MOONBLAST     if GameData::Move.exists?(:MOONBLAST)
      when :PsychicTerrain
        @npMove = :PSYCHIC       if GameData::Move.exists?(:PSYCHIC)
      when :InverseField
        @npMove = :TRICKROOM     if GameData::Move.exists?(:TRICKROOM)
      when :RockyField
        @npMove = :ROCKSMASH     if GameData::Move.exists?(:ROCKSMASH)
      when :CorrosiveField
        @npMove = :ACIDSPRAY	   if GameData::Move.exists?(:ACIDSPRAY)
      when :CorrosiveMistField
        @npMove = :VENOSHOCK	   if GameData::Move.exists?(:VENOSHOCK)
      when :BurningField
        @npMove = :FLAMETHROWER  if GameData::Move.exists?(:FLAMETHROWER)
      when :DesertField
        @npMove = :SANDTOMB      if GameData::Move.exists?(:SANDTOMB)
    else
      try_move = nil
      case @battle.environment
      when :Grass, :TallGrass, :Forest, :ForestGrass
        try_move = (Settings::MECHANICS_GENERATION >= 6) ? :ENERGYBALL : :SEEDBOMB
      when :MovingWater, :StillWater, :Underwater
        try_move = :HYDROPUMP
      when :Puddle
        try_move = :MUDBOMB
      when :Cave
        try_move = (Settings::MECHANICS_GENERATION >= 6) ? :POWERGEM : :ROCKSLIDE
      when :Rock, :Sand
        try_move = (Settings::MECHANICS_GENERATION >= 6) ? :EARTHPOWER : :EARTHQUAKE
      when :Snow
        try_move = :BLIZZARD
        try_move = :FROSTBREATH if Settings::MECHANICS_GENERATION == 6
        try_move = :ICEBEAM if Settings::MECHANICS_GENERATION >= 7
      when :Ice
        try_move = :ICEBEAM
      when :Volcano
        try_move = :LAVAPLUME
      when :Graveyard
        try_move = :SHADOWBALL
      when :Sky
        try_move = :AIRSLASH
      when :Space
        try_move = :DRACOMETEOR
      when :UltraSpace
        try_move = :PSYSHOCK
      end
      @npMove = try_move if GameData::Move.exists?(try_move)
    end
  end

  def pbEffectAgainstTarget(user, target)
    @battle.pbDisplay(_INTL("{1} turned into {2}!", @name, GameData::Move.get(@npMove).name))
    user.pbUseMoveSimple(@npMove, target.index)
  end
end

# Secret Power
class Battle::Move::EffectDependsOnEnvironment < Battle::Move
  attr_reader :secretPower

  def flinchingMove?; return [6, 10, 12].include?(@secretPower); end

  def pbOnStartUse(user, targets)
    # NOTE: This is Gen 7's list plus some of Gen 6 plus a bit of my own.
    @secretPower = 0   # Body Slam, paralysis
    case @battle.field.terrain
    when :ElectricTerrain
      @secretPower = 1   # Thunder Shock, paralysis
    when :GrassyTerrain
      @secretPower = 2   # Vine Whip, sleep
    when :MistyTerrain
      @secretPower = 3   # Fairy Wind, lower Sp. Atk by 1
    when :PsychicTerrain
      @secretPower = 4   # Confusion, lower Speed by 1
    when :RockyField
      @secretPower = 7   # Rock Throw, flinch
    when :CorrosiveField
      @secretPower = 15  # Acid Spray, poison
    when :CorrosiveMistField
      @secretPower = 15  # Acid Spray, poison
    when :BurningField
      @secretPower = 10  # Incinerate, burn
    when :DesertField
      @secretPower = 8 # Mud Slap, lower Accuracy by 1
    else
      case @battle.environment
      when :Grass, :TallGrass, :Forest, :ForestGrass
        @secretPower = 2    # (Same as Grassy Terrain)
      when :MovingWater, :StillWater, :Underwater
        @secretPower = 5    # Water Pulse, lower Attack by 1
      when :Puddle
        @secretPower = 6    # Mud Shot, lower Speed by 1
      when :Cave
        @secretPower = 7    # Rock Throw, flinch
      when :Rock, :Sand
        @secretPower = 8    # Mud-Slap, lower Acc by 1
      when :Snow, :Ice
        @secretPower = 9    # Ice Shard, freeze
      when :Volcano
        @secretPower = 10   # Incinerate, burn
      when :Graveyard
        @secretPower = 11   # Shadow Sneak, flinch
      when :Sky
        @secretPower = 12   # Gust, lower Speed by 1
      when :Space
        @secretPower = 13   # Swift, flinch
      when :UltraSpace
        @secretPower = 14   # Psywave, lower Defense by 1
      end
    end
  end

  # NOTE: This intentionally doesn't use def pbAdditionalEffect, because that
  #       method is called per hit and this move's additional effect only occurs
  #       once per use, after all the hits have happened (two hits are possible
  #       via Parental Bond).
  def pbEffectAfterAllHits(user, target)
    return if target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if user.hasActiveAbility?(:SHEERFORCE)
    chance = pbAdditionalEffectChance(user, target)
    return if @battle.pbRandom(100) >= chance
    case @secretPower
      when 2
        target.pbSleep if target.pbCanSleep?(user, false, self)
      when 10
        target.pbBurn(user) if target.pbCanBurn?(user, false, self)
      when 0, 1
        target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
      when 9
        target.pbFreeze if target.pbCanFreeze?(user, false, self)
      when 5
        if target.pbCanLowerStatStage?(:ATTACK, user, self)
          target.pbLowerStatStage(:ATTACK, 1, user)
        end
      when 14
        if target.pbCanLowerStatStage?(:DEFENSE, user, self)
          target.pbLowerStatStage(:DEFENSE, 1, user)
        end
      when 3
        if target.pbCanLowerStatStage?(:SPECIAL_ATTACK, user, self)
          target.pbLowerStatStage(:SPECIAL_ATTACK, 1, user)
        end
      when 4, 6, 12
        if target.pbCanLowerStatStage?(:SPEED, user, self)
          target.pbLowerStatStage(:SPEED, 1, user)
        end
      when 8
        if target.pbCanLowerStatStage?(:ACCURACY, user, self)
          target.pbLowerStatStage(:ACCURACY, 1, user)
        end
      when 7, 11, 13
        target.pbFlinch(user)
      when 15
        target.pbPoison if target.pbCanPoison?(user, false, self)
      when 16
        target.pbConfuse if target.pbCanConfuse?(user, false, self)
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    id = :BODYSLAM   # Environment-specific anim
    case @secretPower
      when 1  then id = :THUNDERSHOCK if GameData::Move.exists?(:THUNDERSHOCK)
      when 2  then id = :VINEWHIP if GameData::Move.exists?(:VINEWHIP)
      when 3  then id = :FAIRYWIND if GameData::Move.exists?(:FAIRYWIND)
      when 4  then id = :CONFUSION if GameData::Move.exists?(:CONFUSION)
      when 5  then id = :WATERPULSE if GameData::Move.exists?(:WATERPULSE)
      when 6  then id = :MUDSHOT if GameData::Move.exists?(:MUDSHOT)
      when 7  then id = :ROCKTHROW if GameData::Move.exists?(:ROCKTHROW)
      when 8  then id = :MUDSLAP if GameData::Move.exists?(:MUDSLAP)
      when 9  then id = :ICESHARD if GameData::Move.exists?(:ICESHARD)
      when 10 then id = :INCINERATE if GameData::Move.exists?(:INCINERATE)
      when 11 then id = :SHADOWSNEAK if GameData::Move.exists?(:SHADOWSNEAK)
      when 12 then id = :GUST if GameData::Move.exists?(:GUST)
      when 13 then id = :SWIFT if GameData::Move.exists?(:SWIFT)
      when 14 then id = :PSYWAVE if GameData::Move.exists?(:PSYWAVE)
      when 15 then id = :ACIDSPRAY if GameData::Move.exists?(:ACIDSPRAY)
      when 16 then id = :CONFUSION if GameData::Move.exists?(:CONFUSION)
    end
    super
  end
end

# Camouflage
class Battle::Move::SetUserTypesBasedOnEnvironment < Battle::Move
  TERRAIN_TYPES = {
    :ElectricTerrain => :ELECTRIC,
    :GrassyTerrain   => :GRASS,
    :MistyTerrain    => :FAIRY,
    :PsychicTerrain  => :PSYCHIC,
    :InverseField    => :NORMAL,
    :RockyField      => :ROCK,
    :CorrosiveField  => :POISON,
    :CorrosiveMistField  => :POISON,
    :BurningField    => :FIRE,
    :DesertField     => :GROUND
  }
  ENVIRONMENT_TYPES = {
    :None        => :NORMAL,
    :Grass       => :GRASS,
    :TallGrass   => :GRASS,
    :MovingWater => :WATER,
    :StillWater  => :WATER,
    :Puddle      => :WATER,
    :Underwater  => :WATER,
    :Cave        => :ROCK,
    :Rock        => :GROUND,
    :Sand        => :GROUND,
    :Forest      => :BUG,
    :ForestGrass => :BUG,
    :Snow        => :ICE,
    :Ice         => :ICE,
    :Volcano     => :FIRE,
    :Graveyard   => :GHOST,
    :Sky         => :FLYING,
    :Space       => :DRAGON,
    :UltraSpace  => :PSYCHIC
  }

  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if !user.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @newType = :NORMAL
    terr_type = TERRAIN_TYPES[@battle.field.terrain]
    if terr_type && GameData::Type.exists?(terr_type)
      @newType = terr_type
    else
      @newType = ENVIRONMENT_TYPES[@battle.environment] || :NORMAL
      @newType = :NORMAL if !GameData::Type.exists?(@newType)
    end
    if !GameData::Type.exists?(@newType) || !user.pbHasOtherType?(@newType)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbChangeTypes(@newType)
    typeName = GameData::Type.get(@newType).name
    @battle.pbDisplay(_INTL("{1}'s type changed to {2}!", user.pbThis, typeName))
  end
end



#===============================================================================
# Teleport (Gen 8+)
class Battle::Move::SwitchOutUserStatusMove < Battle::Move
  def pbMoveFailed?(user, targets)
    if user.wild?
      if !@battle.pbCanRun?(user.index) || user.allAllies.length > 0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    elsif !@battle.pbCanChooseNonActive?(user.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
=begin
    #==============================================================
	if @battle.field.terrain == :PsychicTerrain # || @battle.pbCheckGlobalAbility(:PSYSTRESS)
    @battle.pbDisplay(_INTL("The weirdness prevents {1} from switching out!", user.pbThis))
    return
    end
    #==============================================================
=end
    return if user.wild?
    @battle.pbDisplay(_INTL("{1} went back to {2}!", user.pbThis,
                            @battle.pbGetOwnerName(user.index)))
    @battle.pbPursuit(user.index)
    return if user.fainted?
    newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
    return if newPkmn < 0
    @battle.pbRecallAndReplace(user.index, newPkmn)
    @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
    @battle.moldBreaker = false
    @battle.pbOnBattlerEnteringBattle(user.index)
    switchedBattlers.push(user.index)
  end

  def pbEffectGeneral(user)
    if user.wild?
      @battle.pbDisplay(_INTL("{1} fled from battle!", user.pbThis))
      @battle.decision = 3   # Escaped
    end
  end
end

# Flip Turn/U-turn/Volt Switch
class Battle::Move::SwitchOutUserDamagingMove < Battle::Move
  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    #=========================================
    @battle.allBattlers.each do |b|
      if b.hasActiveAbility?(:GUARDDOG)
        @battle.pbShowAbilitySplash(b)
        @battle.pbDisplay(_INTL("{1} can't switch out!",user.pbThis))
        @battle.pbHideAbilitySplash(b)
        return
      end
    end
    #=========================================
=begin
    #==============================================================
	if @battle.field.terrain == :PsychicTerrain # || @battle.pbCheckGlobalAbility(:PSYSTRESS)
    @battle.pbDisplay(_INTL("The weirdness prevents {1} from switching out!", user.pbThis))
    return
    end
    #==============================================================
=end
    return if user.fainted? || numHits == 0 || @battle.pbAllFainted?(user.idxOpposingSide)
    targetSwitched = true
    targets.each do |b|
      targetSwitched = false if !switchedBattlers.include?(b.index)
    end
    return if targetSwitched
    return if !@battle.pbCanChooseNonActive?(user.index)
    @battle.pbDisplay(_INTL("{1} went back to {2}!", user.pbThis,
                            @battle.pbGetOwnerName(user.index)))
    @battle.pbPursuit(user.index)
    return if user.fainted?
    newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
    return if newPkmn < 0
    @battle.pbRecallAndReplace(user.index, newPkmn)
    @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
    @battle.moldBreaker = false
    @battle.pbOnBattlerEnteringBattle(user.index)
    switchedBattlers.push(user.index)
  end
end

# Parting Shot
class Battle::Move::LowerTargetAtkSpAtk1SwitchOutUser < Battle::Move::TargetMultiStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:ATTACK, 1, :SPECIAL_ATTACK, 1]
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
=begin
    #==============================================================
	if @battle.field.terrain == :PsychicTerrain # || @battle.pbCheckGlobalAbility(:PSYSTRESS)
    @battle.pbDisplay(_INTL("The weirdness prevents {1} from switching out!", user.pbThis))
    return
    end
    #==============================================================
=end
    switcher = user
    targets.each do |b|
      next if switchedBattlers.include?(b.index)
      switcher = b if b.effects[PBEffects::MagicCoat] || b.effects[PBEffects::MagicBounce]
    end
    return if switcher.fainted? || numHits == 0
    return if !@battle.pbCanChooseNonActive?(switcher.index)
    @battle.pbDisplay(_INTL("{1} went back to {2}!", switcher.pbThis,
                            @battle.pbGetOwnerName(switcher.index)))
    @battle.pbPursuit(switcher.index)
    return if switcher.fainted?
    newPkmn = @battle.pbGetReplacementPokemonIndex(switcher.index)   # Owner chooses
    return if newPkmn < 0
    @battle.pbRecallAndReplace(switcher.index, newPkmn)
    @battle.pbClearChoice(switcher.index)   # Replacement Pokémon does nothing this round
    @battle.moldBreaker = false if switcher.index == user.index
    @battle.pbOnBattlerEnteringBattle(switcher.index)
    switchedBattlers.push(switcher.index)
  end
end

# Baton Pass 
class Battle::Move::SwitchOutUserPassOnEffects < Battle::Move
  def pbMoveFailed?(user, targets)
    if !@battle.pbCanChooseNonActive?(user.index) # || @battle.field.terrain == :Psychic || @battle.pbCheckGlobalAbility(:PSYSTRESS)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
=begin
    #==============================================================
	if @battle.field.terrain == :PsychicTerrain # || @battle.pbCheckGlobalAbility(:PSYSTRESS)
    @battle.pbDisplay(_INTL("The weirdness prevents {1} from switching out!", user.pbThis))
    return
    end
    #==============================================================
=end
    return if user.fainted? || numHits == 0
    return if !@battle.pbCanChooseNonActive?(user.index)
    @battle.pbPursuit(user.index)
    return if user.fainted?
    newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
    return if newPkmn < 0
    @battle.pbRecallAndReplace(user.index, newPkmn, false, true)
    @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
    @battle.moldBreaker = false
    @battle.pbOnBattlerEnteringBattle(user.index)
    switchedBattlers.push(user.index)
  end
end

# Wild Charge
class Battle::Move::RecoilQuarterOfDamageDealt < Battle::Move::RecoilMove
  def pbRecoilDamage(user, target)
    return (target.damageState.totalHPLost / 8.0).round if [:ElectricTerrain].include?(user.battle.field.terrain) && [:WILDCHARGE].include?(@id)
    return (target.damageState.totalHPLost / 4.0).round
  end
end

# Cosmic Power
class Battle::Move::RaiseUserDefSpDef1 < Battle::Move::MultiStatUpMove
  def initialize(battle, move)
    super
    if [:COSMICPOWER].include?(@id) && [:MistyTerrain, :PsychicTerrain].include?(battle.field.terrain)
      @statUp = [:DEFENSE, 2, :SPECIAL_DEFENSE, 2]
    else
      @statUp = [:DEFENSE, 1, :SPECIAL_DEFENSE, 1]
    end
  end
end

# Calm Mind
class Battle::Move::RaiseUserSpAtkSpDef1 < Battle::Move::MultiStatUpMove
  def initialize(battle, move)
    super
    if [:CALMMIND].include?(@id) && [:PsychicTerrain].include?(battle.field.terrain)
      @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    else
      @statUp = [:SPECIAL_ATTACK, 1, :SPECIAL_DEFENSE, 1]
    end
  end
end

# Meditate
class Battle::Move::RaiseUserAttack1 < Battle::Move::StatUpMove
  def initialize(battle, move)
    super
    if [:MEDITATE].include?(@id) && [:PsychicTerrain].include?(battle.field.terrain)
      @statUp = [:ATTACK, 3]
    else
      @statUp = [:ATTACK, 1]
    end
  end
end

# Psyshield Bash
class Battle::Move::RaiseUserDefense1 < Battle::Move::StatUpMove
  def initialize(battle, move)
    super
    if [:PSYSHIELDBASH].include?(@id) && [:PsychicTerrain].include?(battle.field.terrain)
      @statUp = [:DEFENSE, 2]
    else
      @statUp = [:DEFENSE, 1]
    end
  end
end

# Wonder Room
class Battle::Move::StartSwapAllBattlersBaseDefensiveStats < Battle::Move
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::WonderRoom] > 0
      @battle.field.effects[PBEffects::WonderRoom] = 0
      @battle.pbDisplay(_INTL("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!"))
    else
      if [:PSYCHICTERRAIN].include?(user.battle.field.terrain)
        @battle.field.effects[PBEffects::WonderRoom] = 8
      else
        @battle.field.effects[PBEffects::WonderRoom] = 5
      end
      @battle.pbDisplay(_INTL("It created a bizarre area in which the Defense and Sp. Def stats are swapped!"))
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    return if @battle.field.effects[PBEffects::WonderRoom] > 0   # No animation
    super
  end
end

# Esper Wing
class Battle::Move::RaiseUserSpeed1 < Battle::Move::StatUpMove
  def initialize(battle, move)
    super
    if [:ESPERWING].include?(@id) && [:PSYCHICTERRAIN].include?(battle.field.terrain)
      @statUp = [:SPEED, 2]
    else
      @statUp = [:SPEED, 1]
    end
  end
end

# Magic Room
class Battle::Move::StartNegateHeldItems < Battle::Move
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::MagicRoom] > 0
      @battle.field.effects[PBEffects::MagicRoom] = 0
      @battle.pbDisplay(_INTL("The area returned to normal!"))
    else
      if [:PSYCHICTERRAIN].include?(user.battle.field.terrain)
        @battle.field.effects[PBEffects::MagicRoom] = 8
      else
        @battle.field.effects[PBEffects::MagicRoom] = 5
      end
      @battle.pbDisplay(_INTL("It created a bizarre area in which Pokémon's held items lose their effects!"))
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    return if @battle.field.effects[PBEffects::MagicRoom] > 0   # No animation
    super
  end
end

# Trick Room
class Battle::Move::StartSlowerBattlersActFirst < Battle::Move
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::TrickRoom] > 0
      @battle.field.effects[PBEffects::TrickRoom] = 0
      @battle.pbDisplay(_INTL("{1} reverted the dimensions!", user.pbThis))
    else
      if [:PSYCHICTERRAIN].include?(user.battle.field.terrain)
        @battle.field.effects[PBEffects::TrickRoom] = 8
      else
        @battle.field.effects[PBEffects::TrickRoom] = 5
      end
      @battle.pbDisplay(_INTL("{1} twisted the dimensions!", user.pbThis))
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    return if @battle.field.effects[PBEffects::TrickRoom] > 0   # No animation
    super
  end
end

# Gravity
class Battle::Move::StartGravity < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.effects[PBEffects::Gravity] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    if [:PSYCHICTERRAIN].include?(user.battle.field.terrain)
      @battle.field.effects[PBEffects::Gravity] = 8
    else
      @battle.field.effects[PBEffects::Gravity] = 5
    end
    @battle.pbDisplay(_INTL("Gravity intensified!"))
    @battle.allBattlers.each do |b|
      showMessage = false
      if b.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                            "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                            "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
        b.effects[PBEffects::TwoTurnAttack] = nil
        @battle.pbClearChoice(b.index) if !b.movedThisRound?
        showMessage = true
      end
      if b.effects[PBEffects::MagnetRise] > 0 ||
         b.effects[PBEffects::Telekinesis] > 0 ||
         b.effects[PBEffects::SkyDrop] >= 0
        b.effects[PBEffects::MagnetRise]  = 0
        b.effects[PBEffects::Telekinesis] = 0
        b.effects[PBEffects::SkyDrop]     = -1
        showMessage = true
      end
      if showMessage
        @battle.pbDisplay(_INTL("{1} couldn't stay airborne because of gravity!", b.pbThis))
      end
    end
  end
end

# Mind Reader
class Battle::Move::EnsureNextMoveAlwaysHits < Battle::Move
  def pbEffectAgainstTarget(user, target)
    user.effects[PBEffects::LockOn]    = 2
    user.effects[PBEffects::LockOnPos] = target.index
    @battle.pbDisplay(_INTL("{1} took aim at {2}!", user.pbThis, target.pbThis(true)))
    if [:MINDREADER].include?(@id) && [:PsychicTerrain].include?(user.battle.field.terrain)
      user.pbRaiseStatStage(:SPECIAL_ATTACK, 2, user)
    end
  end
end

# Miracle Eye
class Battle::Move::StartNegateTargetEvasionStatStageAndDarkImmunity < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::MiracleEye] = true
    @battle.pbDisplay(_INTL("{1} was identified!", target.pbThis))
    if [:MIRACLEEYE].include?(@id) && [:PsychicTerrain].include?(user.battle.field.terrain)
      user.pbRaiseStatStage(:SPECIAL_ATTACK, 2, user)
    end
  end
end

# Telekinesis
class Battle::Move::StartTargetAirborneAndAlwaysHitByMoves < Battle::Move
  def unusableInGravity?; return true; end
  def canMagicCoat?;      return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::Ingrain] ||
       target.effects[PBEffects::SmackDown] ||
       target.effects[PBEffects::Telekinesis] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.isSpecies?(:DIGLETT) ||
       target.isSpecies?(:DUGTRIO) ||
       target.isSpecies?(:SANDYGAST) ||
       target.isSpecies?(:PALOSSAND) ||
       (target.isSpecies?(:GENGAR) && target.mega?)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Telekinesis] = 3
    @battle.pbDisplay(_INTL("{1} was hurled into the air!", target.pbThis))
    if [:PsychicTerrain].include?(user.battle.field.terrain)
      target.pbLowerStatStage(:DEFENSE, 2, target)
      target.pbLowerStatStage(:SPECIAL_DEFENSE, 2, target, false)
    end
  end
end

# Nasty Plot
class Battle::Move::RaiseUserSpAtk2 < Battle::Move::StatUpMove
  def initialize(battle, move)
    super
    if [:NASTYPLOT].include?(@id) && [:PsychicTerrain].include?(battle.field.terrain)
      @statUp = [:SPECIAL_ATTACK, 3]
    else
      @statUp = [:SPECIAL_ATTACK, 2]
    end
  end
end

# Eerie Impulse
class Battle::Move::LowerTargetSpAtk2 < Battle::Move::TargetStatDownMove
  def initialize(battle, move)
    super
    if [:ElectricTerrain].include?(battle.field.terrain)
      @statDown = [:SPECIAL_ATTACK, 3]
    else
      @statDown = [:SPECIAL_ATTACK, 2]
    end
  end
end

# Cotton Spore
class Battle::Move::LowerTargetSpeed2 < Battle::Move::TargetStatDownMove
  def initialize(battle, move)
    super
    if [:GrassyTerrain].include?(battle.field.terrain) && [:COTTONSPORE].include?(@id)
      @statDown = [:SPEED, 3]
    else
      @statDown = [:SPEED, 2]
    end
  end
end


=begin
#============================
# DEFEND ORDER [ EXAMPLE FIELD]
#============================
class Battle::Move::RaiseUserDefSpDef1 < Battle::Move::MultiStatUpMove
  def initialize(battle, move)
    super
	if @id == :DEFENDORDER 
	  if $game_temp.fieldEffectsBg == 1 # Example Field
       @statUp = [:DEFENSE,2,:SPECIAL_DEFENSE,2] 
	  end
	else
	   @statUp = [:DEFENSE,1,:SPECIAL_DEFENSE,1]
	end
  end
end

#============================
# HEAL ORDER [ EXAMPLE FIELD]
#============================
class Battle::Move::HealUserHalfOfTotalHP < Battle::Move::HealingMove
  def pbHealAmount(user)
	if @id == :HEALORDER 
		if $game_temp.fieldEffectsBg == 1 # Example Field
			return (user.totalhp*0.66).round
		end
	else
		return (user.totalhp/2.0).round
	end
  end
end

#============================
# WOOD HAMMER [ EXAMPLE FIELD]
#============================
class Battle::Move::RecoilThirdOfDamageDealt < Battle::Move::RecoilMove
  def pbRecoilDamage(user, target)
	return if @id == :WOODHAMMER && ($game_temp.fieldEffectsBg == 2 && $game_temp.terrainEffectsBg == 1) # Forest + Grassy Overlay
    return (target.damageState.totalHPLost / 3.0).round 
  end
  
  def pbAdditionalEffect(user, target)
    if @id == :WOODHAMMER
		if $game_temp.fieldEffectsBg == 1 # Example Field
		   user.pbBurn(user) if user.pbCanBurn?(user, false, self)
		end
	end
  end
end

#============================
# FOREST'S CURSE [ EXAMPLE FIELD ]
#============================
class Battle::Move::AddGrassTypeToTarget < Battle::Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !GameData::Type.exists?(:GRASS) || target.pbHasType?(:GRASS) || !target.canChangeType?
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Type3] = :GRASS
    typeName = GameData::Type.get(:GRASS).name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", target.pbThis, typeName))
	case $game_temp.fieldEffectsBg
		when 1 # Example Field
		  target.effects[PBEffects::LeechSeed] = user.index
          @battle.pbDisplay(_INTL("{1} was seeded!",target.pbThis))
	end
  end
end
=end