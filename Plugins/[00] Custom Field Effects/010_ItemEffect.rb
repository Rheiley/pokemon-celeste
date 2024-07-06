#===============================================================================
# Items Affected by Field
#=============================================================================== 01/05
# Electric Seed
Battle::ItemEffects::TerrainStatBoost.add(:ELECTRICSEED,
  proc { |item, battler, battle|
    next false if ![:ElectricTerrain, :ElectricField].include?(battle.field.terrain)
    next false if !battler.pbCanRaiseStatStage?(:DEFENSE, battler)
    itemName = GameData::Item.get(item).name
	battle.pbCommonAnimation("UseItem", battler)
	if [:ElectricField].include?(battle.field.terrain)
    battle.pbDisplay(_INTL("{1} began charging power!", battler.pbThis))
	battler.effects[PBEffects::Charge] = 2
    end
	next battler.pbRaiseStatStageByCause(:DEFENSE, 1, battler, itemName)
  }
)

#=============================================================================== 02/06
# Grassy Seed
Battle::ItemEffects::TerrainStatBoost.add(:GRASSYSEED,
  proc { |item, battler, battle|
    next false if ![:GrassyTerrain, :GrassyField].include?(battle.field.terrain)
    next false if !battler.pbCanRaiseStatStage?(:DEFENSE, battler)
    itemName = GameData::Item.get(item).name
    battle.pbCommonAnimation("UseItem", battler)
	if [:GrassyField].include?(battle.field.terrain)
    battle.pbDisplay(_INTL("{1} planted its roots!", battler.pbThis))
	battler.effects[PBEffects::Ingrain] = true
    end	
    next battler.pbRaiseStatStageByCause(:DEFENSE, 1, battler, itemName)
  }
)

#=============================================================================== 03/07
# Misty Seed
Battle::ItemEffects::TerrainStatBoost.add(:MISTYSEED,
  proc { |item, battler, battle|
    next false if ![:MistyTerrain, :MistyField].include?(battle.field.terrain)
    next false if !battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
    itemName = GameData::Item.get(item).name
    battle.pbCommonAnimation("UseItem", battler)
	if [:MistyField].include?(battle.field.terrain)
    battle.pbDisplay(_INTL("{1} made a healing wish!", battler.pbThis))
    battle.positions[battler.index].effects[PBEffects::HealingWish] = true
    end	
    next battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE, 1, battler, itemName)
  }
)

#=============================================================================== 04/08
# Psychic Seed
Battle::ItemEffects::TerrainStatBoost.add(:PSYCHICSEED,
  proc { |item, battler, battle|
    next false if ![:PsychicTerrain, :PsychicField].include?(battle.field.terrain)
    next false if !battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
    itemName = GameData::Item.get(item).name
    battle.pbCommonAnimation("UseItem", battler)
    next battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE, 1, battler, itemName)
  }
)