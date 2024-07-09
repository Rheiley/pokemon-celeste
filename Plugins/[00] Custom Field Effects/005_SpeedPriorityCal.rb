#=============================================================================
# Speed Calculation
#=============================================================================
class Battle::Battler
  alias fieldEffects_pbSpeed pbSpeed
  def pbSpeed
    return 1 if fainted?
    stage = @stages[:SPEED] + STAT_STAGE_MAXIMUM
    speed = @speed * STAT_STAGE_MULTIPLIERS[stage] / STAT_STAGE_DIVISORS[stage]
    speedMult = 1.0   
#=============================================================================
# Global Speed Calculation
=begin
	speedMult *= 1 if pbOwnedByPlayer?	
	speedMult *= 1 if !pbOwnedByPlayer?
=end
#=============================================================================
# Terrain-Based Speed Calculation
	speedMult *= 2 if [:ElectricTerrain].include?(@battle.field.terrain) && hasActiveAbility?(:SURGESURFER)
=begin
    if pbHasType?(:ELECTRIC)
	if isSpecies?(:PIKACHU)
	if hasActiveItem?(:)
=end
#=============================================================================
    return [(speed * speedMult).round, 1].max
    ret = fieldEffects_pbSpeed
    ret
  end
end

#=============================================================================
# Priority Calculation
#=============================================================================
class Battle
  def pbFieldPriorityCal(entry)
  fieldpri = 0
#=============================================================================  
  #fieldpri = 2 if [:RockyField].include?(@field.terrain) && entry[0].pbHasType?(:FLYING)
  #fieldpri = 1 if [:RockyField].include?(@field.terrain) && entry[0].isSpecies?(:PIKACHU)
#============================================================================= 
  fieldpri
  end
end 

#=============================================================================
# Priority Calculation Main
#=============================================================================
class Battle
  def pbCalculatePriority(fullCalc = false, indexArray = nil)
    needRearranging = false
    if fullCalc
      @priorityTrickRoom = (@field.effects[PBEffects::TrickRoom] > 0)
      # Recalculate everything from scratch
      randomOrder = Array.new(maxBattlerIndex + 1) { |i| i }
      (randomOrder.length - 1).times do |i|   # Can't use shuffle! here
        r = i + pbRandom(randomOrder.length - i)
        randomOrder[i], randomOrder[r] = randomOrder[r], randomOrder[i]
      end
      @priority.clear
      (0..maxBattlerIndex).each do |i|
        b = @battlers[i]
        next if !b
        # [battler, speed, sub-priority from ability, sub-priority from item,
        #  final sub-priority, priority, tie-breaker order]
        entry = [b, b.pbSpeed, 0, 0, 0, 0, randomOrder[i]]
        if @choices[b.index][0] == :UseMove || @choices[b.index][0] == :Shift
          # Calculate move's priority
          if @choices[b.index][0] == :UseMove
            move = @choices[b.index][2]
            pri = move.pbPriority(b)
            if b.abilityActive?
              pri = Battle::AbilityEffects.triggerPriorityChange(b.ability, b, move, pri)
            end
            entry[5] = pri
            @choices[b.index][4] = pri
          end
          # Calculate sub-priority changes (first/last within priority bracket)
          # Abilities (Stall)
          if b.abilityActive?
            entry[2] = Battle::AbilityEffects.triggerPriorityBracketChange(b.ability, b, self)
          end
          # Items (Quick Claw, Custap Berry, Lagging Tail, Full Incense)
          if b.itemActive?
            entry[3] = Battle::ItemEffects.triggerPriorityBracketChange(b.item, b, self)
          end
        end
        @priority.push(entry)
      end
      needRearranging = true
    else
      if (@field.effects[PBEffects::TrickRoom] > 0) != @priorityTrickRoom
        needRearranging = true
        @priorityTrickRoom = (@field.effects[PBEffects::TrickRoom] > 0)
      end
      # Recheck all battler speeds and changes to priority caused by abilities
      @priority.each do |entry|
        next if !entry
        next if indexArray && !indexArray.include?(entry[0].index)
        # Recalculate speed of battler
        newSpeed = entry[0].pbSpeed
        needRearranging = true if newSpeed != entry[1]
        entry[1] = newSpeed
        # Recalculate move's priority in case ability has changed
        choice = @choices[entry[0].index]
        if choice[0] == :UseMove
          move = choice[2]
          pri = move.pbPriority(entry[0])
          if entry[0].abilityActive?
            pri = Battle::AbilityEffects.triggerPriorityChange(entry[0].ability, entry[0], move, pri)
          end
          needRearranging = true if pri != entry[5]
          entry[5] = pri
          choice[4] = pri
        end
        # NOTE: If the battler's ability at the start of this round was one with
        #       a PriorityBracketChange handler (i.e. Quick Draw), but it Mega
        #       Evolved and now doesn't have that ability, that old ability's
        #       priority bracket modifier will still apply. Similarly, if its
        #       old ability did not have a PriorityBracketChange handler but it
        #       Mega Evolved and now does have it, it will not apply this round.
        #       This is because the message saying that it had an effect appears
        #       before Mega Evolution happens, and recalculating it now would
        #       make that message inaccurate because Quick Draw only has a
        #       chance of triggering. However, since Quick Draw is exclusive to
        #       a species that doesn't Mega Evolve, these circumstances should
        #       never arise and no one will notice that the priority bracket
        #       change isn't recalculated when technically it should be.
      end
    end
    # Calculate each battler's overall sub-priority, and whether its ability or
    # item is responsible
    # NOTE: Going fast beats going slow. A Pokémon with Stall and Quick Claw
    #       will go first in its priority bracket if Quick Claw triggers,
    #       regardless of Stall.
    @priority.each do |entry|
      entry[0].effects[PBEffects::PriorityAbility] = false
      entry[0].effects[PBEffects::PriorityItem] = false
      subpri = entry[2]   # Sub-priority from ability
      if (subpri == 0 && entry[3] != 0) ||   # Ability has no effect, item has effect
         (subpri < 0 && entry[3] >= 1)   # Ability makes it slower, item makes it faster
        subpri = entry[3]   # Sub-priority from item
        entry[0].effects[PBEffects::PriorityItem] = true
      elsif subpri != 0   # Ability has effect, item had superfluous/no effect
        entry[0].effects[PBEffects::PriorityAbility] = true
      end
#===============================================================================
      # Terrain-Based Sub-Priority Calculation
      fieldpri = pbFieldPriorityCal(entry)
	  entry[4] = subpri + fieldpri  # Final sub-priority
#===============================================================================
    end
    # Reorder the priority array
    if needRearranging
      @priority.sort! do |a, b|
        if a[5] != b[5]
          # Sort by priority (highest value first)
          b[5] <=> a[5]
        elsif a[4] != b[4]
          # Sort by sub-priority (highest value first)
          b[4] <=> a[4]
        elsif @priorityTrickRoom
          # Sort by speed (lowest first), and use tie-breaker if necessary
          (a[1] == b[1]) ? b[6] <=> a[6] : a[1] <=> b[1]
        else
          # Sort by speed (highest first), and use tie-breaker if necessary
          (a[1] == b[1]) ? b[6] <=> a[6] : b[1] <=> a[1]
        end
      end
      # Write the priority order to the debug log
      if fullCalc && $INTERNAL
        logMsg = "[Round order] "
        @priority.each_with_index do |entry, i|
          logMsg += ", " if i > 0
          logMsg += "#{entry[0].pbThis(i > 0)} (#{entry[0].index})"
        end
        PBDebug.log(logMsg)
      end
    end
  end
end