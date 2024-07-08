#=============================================================================
# Damage Calculation
#=============================================================================
#.isSpecies?(:) .pbHasType?(:) .hasActiveAbility?(:) .hasActiveItem?(:) [:].include?(user.status) pbHasStatus?(:)
#@battle.pbOwnSide.effects[] @battle.pbOpposingSide.effects[] @battle.field.effects[] @battle.pbCheckGlobalAbility(:)
#[:].include?(.effectiveWeather) .affectedByTerrain? [:].include?(@id) .effects[]
#type == : physicalMove? specialMove? contactMove? soundMove? recoilMove? multiHitMove? punchingMove? bitingMove? pulseMove? bombMove?
class Battle::Move
  alias fieldEffects_pbCalcDamageMultipliers pbCalcDamageMultipliers
  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
#=============================================================================
# Global Damage Calculation
#=begin
#   if !target.pbOwnedByPlayer?
#	multipliers[:power_multiplier] *= 0.9
#	multipliers[:defense_multiplier] *= 1.1
#	multipliers[:final_damage_multiplier] *= 0.9
#	end
#    if target.pbOwnedByPlayer?
#	multipliers[:power_multiplier] *= 1.1
#	multipliers[:defense_multiplier] *= 0.9
#	multipliers[:final_damage_multiplier] *= 1.1
#	end

#	if target.isSpecies?(:LARVITAR)
#	multipliers[:defense_multiplier] *= 2
#	end
#	if user.isSpecies?(:LARVITAR)
#	multipliers[:power_multiplier] *= 2
#	end
#=end

# NONE OF THIS CODE WORKS IDK WHY
#=============================================================================
	case @battle.field.terrain
#============================================================================= 01
    when :ElectricTerrain
	if type == :ELECTRIC && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 1.3
	@battle.pbDisplay(_INTL("The current strengthened the attack!"))
	end
    if user.hasActiveAbility?(:HADRONENGINE) && specialMove?
	@battle.pbShowAbilitySplash(user)
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
	@battle.pbHideAbilitySplash(user)
	end
	if user.hasActiveAbility?(:GALVANIZE) && powerBoost
	@battle.pbShowAbilitySplash(user)
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
	@battle.pbHideAbilitySplash(user)
	end	
	if [:RISINGVOLTAGE].include?(@id) && target.affectedByTerrain?
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
	end
	if [:PSYBLADE].include?(@id)
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
	end
	if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
	end
#============================================================================= 02
	when :GrassyTerrain
	if type == :GRASS && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 1.3
	@battle.pbDisplay(_INTL("The grass strengthened the attack!"))
	end
	if [:GRASSYGLIDE].include?(@id) && user.affectedByTerrain?
	@battle.pbDisplay(_INTL("{1} moves faster on the grass!", @name))
	end
	if [:BULLDOZE, :EARTHQUAKE, :MAGNITUDE].include?(@id)
	@battle.pbDisplay(_INTL("The attack on {1} was weakened by the grass!", target.pbThis))
	end
	if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the grass!", target.pbThis))
	end
#============================================================================= 03
	when :MistyTerrain
	if type == :DRAGON && target.affectedByTerrain?
    multipliers[:power_multiplier] *= 0.5
	@battle.pbDisplay(_INTL("The draconic power weakened..."))
	end
	if user.hasActiveAbility?(:PIXILATE) && powerBoost
	@battle.pbShowAbilitySplash(user)
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
	@battle.pbHideAbilitySplash(user)	
	end
	if [:MISTYEXPLOSION].include?(@id)
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
	end
	if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
	end
#============================================================================= 04
    when :PsychicTerrain
	if type == :PSYCHIC && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 1.3
	@battle.pbDisplay(_INTL("The weirdness boosted the attack!"))
    end
    if [:EXPANDINGFORCE].include?(@id) && user.affectedByTerrain?
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the weirdness!", target.pbThis))
	end
    if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the weirdness!", target.pbThis))
	end
#============================================================================= 05
    when :ElectricField
	if type == :ELECTRIC && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 1.3
	@battle.pbDisplay(_INTL("The current strengthened the attack!"))
	end	
    if user.hasActiveAbility?(:HADRONENGINE) && specialMove?
    multipliers[:power_multiplier] *= 4 / 3.0
	@battle.pbShowAbilitySplash(user)
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
	@battle.pbHideAbilitySplash(user)	
	end
	if user.hasActiveAbility?(:GALVANIZE) && powerBoost
    multipliers[:power_multiplier] *= 1.25
	@battle.pbShowAbilitySplash(user)
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
	@battle.pbHideAbilitySplash(user)
	end	
	if user.isSpecies?(:ZAPDOS)
	multipliers[:power_multiplier] *= 1.5
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))	
	end
	if user.isSpecies?(:MAGNEMITE)
	multipliers[:power_multiplier] *= 2
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))	
	end	
	if [:EXPLOSION, :SELFDESTRUCT, :SURF, :MUDDYWATER, :HURRICANE, :SMACKDOWN, :THOUSANDARROWS].include?(@id) && user.affectedByTerrain?
	multipliers[:power_multiplier] *= 1.3
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
	end
	if [:PSYBLADE].include?(@id)
	multipliers[:power_multiplier] *= 1.5
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
	end
	if [:TERRAINPULSE, :MAGNETBOMB, :PLASMAFISTS].include?(@id) && user.affectedByTerrain?
	multipliers[:power_multiplier] *= 2
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
	end 
	if [:RISINGVOLTAGE].include?(@id) && target.affectedByTerrain?
	multipliers[:power_multiplier] *= 2
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the current!", target.pbThis))
	end
	if type == :ELECTRIC && target.affectedByTerrain? && [:PARALYSIS].include?(target.status)
    multipliers[:power_multiplier] *= 1.3
	@battle.pbDisplay(_INTL("{1} was hurt even more because its paralysis!", target.pbThis))
	end	
#============================================================================= 06
	when :GrassyField
	if type == :GRASS && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 1.5
	@battle.pbDisplay(_INTL("The grass strengthened the attack!"))
	end
	if type == :FIRE && target.affectedByTerrain?
    multipliers[:power_multiplier] *= 1.5
	@battle.pbDisplay(_INTL("The fire burned the grass!"))
	end
	if [:GRASSYGLIDE].include?(@id) && user.affectedByTerrain?
	@battle.pbDisplay(_INTL("{1} moves faster on the grass!", @name))
	end
	if [:BULLDOZE, :EARTHQUAKE, :MAGNITUDE, :SURF, :MUDDYWATER].include?(@id)
    multipliers[:power_multiplier] *= 0.5
	@battle.pbDisplay(_INTL("The attack on {1} was weakened by the grass!", target.pbThis))
	end
	if [:FAIRYWIND, :SILVERWIND].include?(@id)
    multipliers[:power_multiplier] *= 1.5
	@battle.pbDisplay(_INTL("The wind blew the grass up!"))
	end
	if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
	multipliers[:power_multiplier] *= 2
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the grass!", target.pbThis))
	end
	if target.hasActiveAbility?(:GRASSPELT)
    multipliers[:defense_multiplier] *= 1.5
	@battle.pbShowAbilitySplash(target)
	@battle.pbDisplay(_INTL("The grass protected {1}!", target.pbThis))
	@battle.pbHideAbilitySplash(target)
	end
#============================================================================= 07
	when :MistyField
	if target.pbHasType?(:FAIRY) && target.affectedByTerrain? && specialMove?
	multipliers[:defense_multiplier] *= 1.5
	@battle.pbDisplay(_INTL("The mist protected {1}!", target.pbThis))
	end
	if type == :DRAGON && target.affectedByTerrain?
    multipliers[:power_multiplier] *= 0.5
	@battle.pbDisplay(_INTL("The draconic power weakened..."))
	end
	if type == :FAIRY && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 1.5
	@battle.pbDisplay(_INTL("The mist strengthened the attack!"))
	end
	if target.hasActiveAbility?(:MARVELSCALE)
    multipliers[:defense_multiplier] *= 1.5
	@battle.pbShowAbilitySplash(target)
	@battle.pbDisplay(_INTL("The mist protected {1}!", target.pbThis))
	@battle.pbHideAbilitySplash(target)
	end
	if user.hasActiveAbility?(:PIXILATE) && powerBoost
    multipliers[:power_multiplier] *= 1.25
	@battle.pbShowAbilitySplash(user)
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
	@battle.pbHideAbilitySplash(user)	
	end
	if [:DARKPULSE, :NIGHTDAZE,:SHADOWBALL].include?(@id)
    multipliers[:power_multiplier] *= 0.5
	@battle.pbDisplay(_INTL("The attack on {1} was weakened by the mist!", target.pbThis))
	end
	if [:MISTYEXPLOSION, :MYSTICALFIRE, :MAGICALLEAF, :DOOMDESIRE, :HIDDENPOWER, :ICYWIND, :AURASPHERE].include?(@id) ||
	   [:MISTBALL, :STEAMERUPTION, :CLEARSMOG, :SMOG, :SILVERWIND, :STRANGESTEAM, :MOONGEISTBEAM].include?(@id)
    multipliers[:power_multiplier] *= 1.5
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
	end
	if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
	multipliers[:power_multiplier] *= 2
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the mist!", target.pbThis))
	end
#============================================================================= 08
    when :PsychicField
	if type == :PSYCHIC && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 1.5
	@battle.pbDisplay(_INTL("The weirdness boosted the attack!"))
    end
    if [:EXPANDINGFORCE, :MYSTICALFIRE, :MAGICALLEAF, :AURASPHERE, :HEX, :MOONBLAST, :MINDBLOWN].include?(@id) && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 1.5
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the weirdness!", target.pbThis))
	end
    if [:TERRAINPULSE].include?(@id) && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 2
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the weirdness!", target.pbThis))
	end
#============================================================================= 09
    when :InverseField
	if type == :NORMAL && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 1.5
	@battle.pbDisplay(_INTL("!kcatta eht detsoob dleif ehT"))
    end
	if user.hasActiveAbility?(:NORMALIZE) && powerBoost
    multipliers[:power_multiplier] *= 1.25
	@battle.pbShowAbilitySplash(user)
	@battle.pbDisplay(_INTL("!dleif eht yb decnahne saw {1} no kcatta ehT", target.pbThis))
	@battle.pbHideAbilitySplash(user)	
	end
#============================================================================= 10
    when :RockyField
    if [:TERRAINPULSE, :EARTHQUAKE, :MAGNITUDE, :ROCKCLIMB, :STRENGTH, :BULLDOZE, :HEADBUTT].include?(@id)
	@battle.pbDisplay(_INTL("{1} changed to Rock type!", @name))
	end
	if type == :ROCK && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 1.3
	@battle.pbDisplay(_INTL("The rock boosted the attack on {1}!", target.pbThis))
    end
	if user.isSpecies?(:AERODACTYL)
	multipliers[:power_multiplier] *= 1.2
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the rock!", target.pbThis))	
	end
    if [:TERRAINPULSE, :ROCKSMASH].include?(@id) && user.affectedByTerrain?
    multipliers[:power_multiplier] *= 2
	@battle.pbDisplay(_INTL("The attack on {1} was enhanced by the rock!", target.pbThis))
	end
#============================================================================= 11
    when :CorrosiveField
	if [:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDDYWATER, :WHIRLPOOL, :THOUSANDARROWS].include?(@id)
		@battle.pbDisplay(_INTL("The corrosion strengthened the attack!", @name))
		multipliers[:power_multiplier] *= 1.5
	end
	if [:ACID, :ACIDSPRAY, :GRASSKNOT].include?(@id)
		@battle.pbDisplay(_INTL("The corrosion strengthened the attack!", @name))
		multipliers[:power_multiplier] *= 2
	end
#=============================================================================
    end
	fieldEffects_pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
  end
end

#=begin
#    if user.pokemon.species_data.has_flag?("Legendary")
#	if type == :PSYCHIC && physicalMove? && user.affectedByTerrain?
#	multipliers[:power_multiplier] *= 1.5
#	@battle.pbDisplay(_INTL("The attack gets all beefed up!"))
#	end
#	if type == :BUG && specialMove? && user.affectedByTerrain?
#	multipliers[:power_multiplier] *= 1.5
#	@battle.pbDisplay(_INTL("The attack spreads through the exemplifying power of the field!"))
#	end
#	if target.isSpecies?(:PIKACHU)
#	multipliers[:defense_multiplier] *= 1000
#	end
#	if target.pbHasType?(:ICE) && physicalMove?
#    multipliers[:defense_multiplier] *= 1.2
#	@battle.pbDisplay(_INTL(""))
#	end
#    if contactMove?
#	multipliers[:power_multiplier] *= 1.2
#	@battle.pbDisplay(_INTL("The contact move got powered up!"))
#    end
#	if !contactMove?
#	multipliers[:power_multiplier] *= 1.2
#    @battle.pbDisplay(_INTL("The non-contact move went super sayan!"))
#    end
#	if soundMove?
#    multipliers[:power_multiplier] *= 1.1
#    @battle.pbDisplay(_INTL("Echo...echo...echo..."))
#	end
#   if type == :GRASS && user.affectedByTerrain?
#    multipliers[:power_multiplier] *= 0.5
#    @battle.pbDisplay(_INTL("The move got weaker cause the user is touching grass!"))
#    end
#    if type == :FIRE && target.affectedByTerrain?
#    multipliers[:power_multiplier] *= 0.5
#  @battle.pbDisplay(_INTL("The enemy is touching grass, which makes the move weaker!")) 
#   end
#	if @id == :GRAVAPPLE
#	multipliers[:power_multiplier] *= 1.5
#	@battle.pbDisplay(_INTL("An apple fell from the tree!"))
#	end
#	if [:CUT, :PSYCHOCUT, :FURYCUTTER].include?(@id)
#	multipliers[:power_multiplier] *= 1.5
#	@battle.pbDisplay(_INTL("A tree fell onto {1}!",target.pbThis(true)))
#	end 
#	if [:SURF, :MUDDYWATER, :ROCKTHROW].include?(@id)
#	multipliers[:power_multiplier] *= 0.5
#	@battle.pbDisplay(_INTL("The attack got weaker!"))
#	end
#    if @id == :HURRICANE
#   multipliers[:power_multiplier] *= 2
#	@battle.pbDisplay(_INTL("Multiple trees fell on {1}!",target.pbThis(true)))
#	end
#	if @id == :ATTACKORDER
#	multipliers[:power_multiplier] *= 1.5
#	@battle.pbDisplay(_INTL("The wild bugs joined the attack!"))
#	end
#=end