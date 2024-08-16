#===============================================================================
# Field Register
#===============================================================================
GameData::BattleTerrain.register({:id => :None,               :name => _INTL("None")})               # 00 None
GameData::BattleTerrain.register({:id => :ElectricTerrain,    :name => _INTL("ElectricTerrain")})    # 01 Electric Terrain
GameData::BattleTerrain.register({:id => :GrassyTerrain,      :name => _INTL("GrassyTerrain")})      # 02 Grassy Terrain
GameData::BattleTerrain.register({:id => :MistyTerrain,       :name => _INTL("MistyTerrain")})       # 03 Misty Terrain
GameData::BattleTerrain.register({:id => :PsychicTerrain,     :name => _INTL("PsychicTerrain")})     # 04 Psychic Terrain
GameData::BattleTerrain.register({:id => :InverseField,       :name => _INTL("InverseField")})       # 05 Inverse Field
GameData::BattleTerrain.register({:id => :RockyField,         :name => _INTL("RockyField")})         # 06 Rocky Field
GameData::BattleTerrain.register({:id => :CorrosiveField,     :name => _INTL("CorrosiveField")})     # 07 Corrosive Field
GameData::BattleTerrain.register({:id => :CorrosiveMistField, :name => _INTL("CorrosiveMistField")}) # 08 Corrosive Mist Field
GameData::BattleTerrain.register({:id => :BurningField,       :name => _INTL("BurningField")})       # 09 Burning Field
GameData::BattleTerrain.register({:id => :DesertField,        :name => _INTL("DesertField")})        # 10 Desert Field

#===============================================================================
# Field Note
#===============================================================================
class Battle 
  def pbFieldStartMessage
    case @field.terrain
      when :ElectricTerrain         then pbDisplay(_INTL("An electric current is running across the battlefield!")) # 01
      when :GrassyTerrain           then pbDisplay(_INTL("Grass is covering the battlefield!"))                     # 02
      when :MistyTerrain            then pbDisplay(_INTL("Mist swirls about the battlefield!"))	                    # 03
      when :PsychicTerrain          then pbDisplay(_INTL("The field became mysterious!"))                           # 04
      when :InverseField    		    then pbDisplay(_INTL("!trats elttaB"))                                          # 05
      when :RockyField	  		      then pbDisplay(_INTL("The field is littered with rocks!"))                      # 06
      when :CorrosiveField  		    then pbDisplay(_INTL("The field is corrupted!"))                                # 07
      when :CorrosiveMistField	    then pbDisplay(_INTL("Corrosive mist settles on the field!"))                   # 08
      when :BurningField            then pbDisplay(_INTL("The field is ablaze!"))                                   # 09
      when :DesertField             then pbDisplay(_INTL("The field is rife with sand."))                           # 10
    end
  end

  def pbFieldEndMessage
    case @field.terrain
      when :ElectricTerrain 		 then pbDisplay(_INTL("The electric current disappeared from the battlefield!")) # 01
      when :GrassyTerrain   		 then pbDisplay(_INTL("The grass disappeared from the battlefield!"))            # 02
      when :MistyTerrain    		 then pbDisplay(_INTL("The mist disappeared from the battlefield!"))             # 03
      when :PsychicTerrain  		 then pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))        # 04
      when :InverseField    	   then pbDisplay(_INTL("!dne elttaB"))                                            # 05
      when :RockyField           then pbDisplay(_INTL("The rocks disappeared from the battlefield!"))            # 06
      when :CorrosiveField       then pbDisplay(_INTL("The corruption disappeared from the battlefield!"))       # 07
      when :CorrosiveMistField   then pbDisplay(_INTL("The corrosive mist disappeared from the battlefield!"))   # 08
      when :BurningField         then pbDisplay(_INTL("The flames disappeared from the battlefield!"))           # 09
      when :DesertField          then pbDisplay(_INTL("The sand disappeared from the battlefield!"))             # 10
    end
  end
end

#===============================================================================
# Set Default Field Effect
#===============================================================================
module BattleCreationHelperMethods
  module_function
  # Sets up various battle parameters and applies special rules.
  def prepare_battle(battle)
    electricTerrainArray = []
    grassyTerrainArray = []
    mistyTerrainArray = []
    psychicTerrainArray = []
    inverseFieldArray = []
    rockyFieldArray = []
    corrosiveFieldArray = []
    corrosiveMistFieldArray = []
    burningFieldArray = []
    desertFieldArray = [32, 33]
#===============================================================================
    battle.defaultWeather = :Rain        if $game_switches[101]
    battle.defaultWeather = :Hail        if $game_switches[102]
    battle.defaultWeather = :Sandstorm   if $game_switches[103]
    battle.defaultWeather = :Sun         if $game_switches[104]
#===============================================================================
    #battle.defaultTerrain = :ElectricField     	 if [002].include?($game_map.map_id)
    battle.defaultTerrain = :ElectricTerrain   		 if $game_switches[121] 
    battle.defaultTerrain = :GrassyTerrain     		 if $game_switches[122] 
    battle.defaultTerrain = :MistyTerrain      		 if $game_switches[123]   
    battle.defaultTerrain = :PsychicTerrain    		 if $game_switches[124]   
    battle.defaultTerrain = :InverseField      		 if $game_switches[125]   
    battle.defaultTerrain = :RockyField        		 if $game_switches[126]   
    battle.defaultTerrain = :CorrosiveField    		 if $game_switches[127]   
	  battle.defaultTerrain = :CorrosiveMistField    if $game_switches[128]   
    battle.defaultTerrain = :BurningField          if $game_switches[129]   
    battle.defaultTerrain = :DesertField           if $game_switches[130] || desertFieldArray.include?($game_map.map_id)
#===============================================================================Need Announcement
    battle.field.effects[PBEffects::FairyLock] = 100         if $game_switches[111]
    battle.field.effects[PBEffects::Gravity] = 100           if $game_switches[112]
    battle.field.effects[PBEffects::IonDeluge] = 100         if $game_switches[113]
    battle.field.effects[PBEffects::MagicRoom] = 100         if $game_switches[114]
    battle.field.effects[PBEffects::MudSportField] = 100     if $game_switches[115] 
    battle.field.effects[PBEffects::TrickRoom] = 100         if $game_switches[116]
	  battle.field.effects[PBEffects::WaterSportField] = 100   if $game_switches[117]
    battle.field.effects[PBEffects::WonderRoom] = 100        if $game_switches[118]
    battle.field.effects[PBEffects::InverseRoom] = 100       if $game_switches[119]
#===============================================================================
    battleRules = $game_temp.battle_rules
    # The size of the battle, i.e. how many Pokémon on each side (default: "single")
    battle.setBattleMode(battleRules["size"]) if !battleRules["size"].nil?
    # Whether the game won't black out even if the player loses (default: false)
    battle.canLose = battleRules["canLose"] if !battleRules["canLose"].nil?
    # Whether the player can choose to run from the battle (default: true)
    battle.canRun = battleRules["canRun"] if !battleRules["canRun"].nil?
    # Whether the player can manually choose to switch out Pokémon (default: true)
    battle.canSwitch = battleRules["canSwitch"] if !battleRules["canSwitch"].nil?
    # Whether wild Pokémon always try to run from battle (default: nil)
    battle.rules["alwaysflee"] = battleRules["roamerFlees"]
    # Whether Pokémon gain Exp/EVs from defeating/catching a Pokémon (default: true)
    battle.expGain = battleRules["expGain"] if !battleRules["expGain"].nil?
    # Whether the player gains/loses money at the end of the battle (default: true)
    battle.moneyGain = battleRules["moneyGain"] if !battleRules["moneyGain"].nil?
    # Whether Poké Balls cannot be thrown at all
    battle.disablePokeBalls = battleRules["disablePokeBalls"] if !battleRules["disablePokeBalls"].nil?
    # Whether the player is asked what to do with a new Pokémon when their party is full
    battle.sendToBoxes = $PokemonSystem.sendtoboxes if Settings::NEW_CAPTURE_CAN_REPLACE_PARTY_MEMBER
    battle.sendToBoxes = 2 if battleRules["forceCatchIntoParty"]
    # Whether the player is able to switch when an opponent's Pokémon faints
    battle.switchStyle = ($PokemonSystem.battlestyle == 0)
    battle.switchStyle = battleRules["switchStyle"] if !battleRules["switchStyle"].nil?
    # Whether battle animations are shown
    battle.showAnims = ($PokemonSystem.battlescene == 0)
    battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
    # Terrain
    if battleRules["defaultTerrain"].nil?
      if Settings::OVERWORLD_WEATHER_SETS_BATTLE_TERRAIN
        case $game_screen.weather_type
        when :Storm
          battle.defaultTerrain = :ElectricTerrain
        when :Fog
          battle.defaultTerrain = :MistyTerrain
        end
      end
    else
      battle.defaultTerrain = battleRules["defaultTerrain"]
    end
    # Weather
    if battleRules["defaultWeather"].nil?
      case GameData::Weather.get($game_screen.weather_type).category
      when :Rain, :Storm
        battle.defaultWeather = :Rain
      when :Hail
        battle.defaultWeather = :Hail
      when :Sandstorm
        battle.defaultWeather = :Sandstorm
      when :Sun
        battle.defaultWeather = :Sun
      end
    else
      battle.defaultWeather = battleRules["defaultWeather"]
    end
    # Environment
    if battleRules["environment"].nil?
      battle.environment = pbGetEnvironment
    else
      battle.environment = battleRules["environment"]
    end
    # Backdrop graphic filename
    if !battleRules["backdrop"].nil?
      backdrop = battleRules["backdrop"]
    elsif $PokemonGlobal.nextBattleBack
      backdrop = $PokemonGlobal.nextBattleBack
    elsif $PokemonGlobal.surfing
      backdrop = "water"   # This applies wherever you are, including in caves
    elsif $game_map.metadata
      back = $game_map.metadata.battle_background
      backdrop = back if back && back != ""
    end
    backdrop = "indoor1" if !backdrop
    battle.backdrop = backdrop
    # Choose a name for bases depending on environment
    if battleRules["base"].nil?
      environment_data = GameData::Environment.try_get(battle.environment)
      base = environment_data.battle_base if environment_data
    else
      base = battleRules["base"]
    end
    battle.backdropBase = base if base
    # Time of day
    if $game_map.metadata&.battle_environment == :Cave
      battle.time = 2   # This makes Dusk Balls work properly in caves
    elsif Settings::TIME_SHADING
      timeNow = pbGetTimeNow
      if PBDayNight.isNight?(timeNow)
        battle.time = 2
      elsif PBDayNight.isEvening?(timeNow)
        battle.time = 1
      else
        battle.time = 0
      end
    end
  end
  
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  def skip_battle?
    return true if $player.able_pokemon_count == 0
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false
  end

  def skip_battle(outcome_variable, trainer_battle = false)
    pbMessage(_INTL("SKIPPING BATTLE...")) if !trainer_battle && $player.pokemon_count > 0
    pbMessage(_INTL("SKIPPING BATTLE...")) if trainer_battle && $DEBUG
    pbMessage(_INTL("AFTER WINNING...")) if trainer_battle && $player.able_pokemon_count > 0
    $game_temp.clear_battle_rules
    if $game_temp.memorized_bgm && $game_system.is_a?(Game_System)
      $game_system.bgm_pause
      $game_system.bgm_position = $game_temp.memorized_bgm_position
      $game_system.bgm_resume($game_temp.memorized_bgm)
    end
    $game_temp.memorized_bgm            = nil
    $game_temp.memorized_bgm_position   = 0
    $PokemonGlobal.nextBattleBGM        = nil
    $PokemonGlobal.nextBattleVictoryBGM = nil
    $PokemonGlobal.nextBattleCaptureME  = nil
    $PokemonGlobal.nextBattleBack       = nil
    $PokemonEncounters.reset_step_count
    outcome = 1   # Win
    outcome = 0 if trainer_battle && $player.able_pokemon_count == 0   # Undecided
    pbSet(outcome_variable, outcome)
    return outcome
  end

  def partner_can_participate?(foe_party)
    return false if !$PokemonGlobal.partner || $game_temp.battle_rules["noPartner"]
    return true if foe_party.length > 1
    if $game_temp.battle_rules["size"]
      return false if $game_temp.battle_rules["size"] == "single" ||
                      $game_temp.battle_rules["size"][/^1v/i]   # "1v1", "1v2", "1v3", etc.
      return true
    end
    return false
  end

  # Generate information for the player and partner trainer(s)
  def set_up_player_trainers(foe_party)
    trainer_array = [$player]
    ally_items    = []
    pokemon_array = $player.party
    party_starts  = [0]
    if partner_can_participate?(foe_party)
      ally = NPCTrainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
      ally.id    = $PokemonGlobal.partner[2]
      ally.party = $PokemonGlobal.partner[3]
      ally_items[1] = ally.items.clone
      trainer_array.push(ally)
      pokemon_array = []
      $player.party.each { |pkmn| pokemon_array.push(pkmn) }
      party_starts.push(pokemon_array.length)
      ally.party.each { |pkmn| pokemon_array.push(pkmn) }
      setBattleRule("double") if $game_temp.battle_rules["size"].nil?
    end
    return trainer_array, ally_items, pokemon_array, party_starts
  end

  def create_battle_scene
    return Battle::Scene.new
  end

  def after_battle(outcome, can_lose)
    $player.party.each do |pkmn|
      pkmn.statusCount = 0 if pkmn.status == :POISON   # Bad poison becomes regular
      pkmn.makeUnmega
      pkmn.makeUnprimal
    end
    if $PokemonGlobal.partner
	  $player.party.each { |pkmn| pkmn.hp = pkmn.totalhp }
      $player.party.each { |pkmn| pkmn.heal }
      #$player.heal_party
      $PokemonGlobal.partner[3].each do |pkmn|
        pkmn.hp = pkmn.totalhp
		pkmn.heal
        pkmn.makeUnmega
        pkmn.makeUnprimal
      end
    end
    if [2, 5].include?(outcome) && can_lose   # if loss or draw
	  $player.party.each { |pkmn| pkmn.hp = pkmn.totalhp }
      $player.party.each { |pkmn| pkmn.heal }
      timer_start = System.uptime
      until System.uptime - timer_start >= 0.25
        Graphics.update
      end
    end
    EventHandlers.trigger(:on_end_battle, outcome, can_lose)
    $game_player.straighten
  end

  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    4 - Wild Pokémon was caught
  #    5 - Draw
  def set_outcome(outcome, outcome_variable = 1, trainer_battle = false)
    case outcome
    when 1, 4   # Won, caught
      $stats.wild_battles_won += 1 if !trainer_battle
      $stats.trainer_battles_won += 1 if trainer_battle
    when 2, 3, 5   # Lost, fled, draw
      $stats.wild_battles_lost += 1 if !trainer_battle
      $stats.trainer_battles_lost += 1 if trainer_battle
    end
    pbSet(outcome_variable, outcome)
  end
end

#===============================================================================
# Start Field
#===============================================================================
class Battle
  def defaultTerrain=(value)
    @field.defaultTerrain  = value
    @field.terrain         = value
    @field.terrainDuration = -1
  end

  def pbStartTerrain(user, newTerrain, fixedDuration = true) # 5 turns
    return if @field.terrain == newTerrain
    @field.terrain = newTerrain
    duration = (fixedDuration) ? 5 : -1
    if duration > 0 && user && user.itemActive?
      duration = Battle::ItemEffects.triggerTerrainExtender(user.item, newTerrain, duration, user, self)
    end
    @field.terrainDuration = duration
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    #pbCommonAnimation(terrain_data.animation) if terrain_data
    pbHideAbilitySplash(user) if user
	  pbFieldStartMessage
	# Set Field Background
	  @scene.pbSetFieldBackground
	# Check for abilities/items that trigger upon the terrain changing
    allBattlers.each { |b| b.pbAbilityOnTerrainChange }
    allBattlers.each { |b| b.pbItemTerrainStatBoostCheck }
  end
  
end

#===============================================================================
# Announce Field
#===============================================================================
class Battle
  def pbStartBattleCore
    # Set up the battlers on each side
    sendOuts = pbSetUpSides
    @battleAI.create_ai_objects
    # Create all the sprites and play the battle intro animation
    @scene.pbStartBattle(self)
    # Show trainers on both sides sending out Pokémon
    pbStartBattleSendOut(sendOuts)
    # Terrain announcement
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    #pbCommonAnimation(terrain_data.animation) if terrain_data
    pbFieldStartMessage
	@scene.pbSetFieldBackground
	# Weather announcement
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
	pbWeatherStartMessage # Gen 9 Pack
=begin
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
    when :Rain        then pbDisplay(_INTL("It is raining."))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("Hail is falling."))
    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The sky is shadowy."))
    end
=end
    # Abilities upon entering battle
    pbOnAllBattlersEnteringBattle
    # Main battle loop
    pbBattleLoop
  end
end 

#=============================================================================
# End Field
#=============================================================================
class Battle
  def pbEOREndTerrain
    # Count down terrain duration
    @field.terrainDuration -= 1 if @field.terrainDuration > 0
    # Terrain wears off
    if @field.terrain != :None && @field.terrainDuration == 0
	  pbFieldEndMessage
      @field.terrain = :None
	  # Set Original Backdrop
      @scene.pbSetFieldBackground
      allBattlers.each { |battler| battler.pbAbilityOnTerrainChange }
      # Start up the default terrain
      if @field.defaultTerrain != :None
        pbStartTerrain(nil, @field.defaultTerrain, false)
        allBattlers.each { |battler| battler.pbAbilityOnTerrainChange }
        allBattlers.each { |battler| battler.pbItemTerrainStatBoostCheck }
      end
      return if @field.terrain == :None
    end
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    #pbCommonAnimation(terrain_data.animation) if terrain_data
    # pbFieldStartMessage
  end  
end

#=============================================================================
# Set Field Background
#=============================================================================
class Battle::Scene
  def pbSetFieldBackground
     if [:None].include?(@battle.field.terrain)
      pbCreateBackdropSprites
     end
     if @battle.field.terrain != :None
      terrain_data = GameData::BattleTerrain.try_get(@battle.field.terrain)
      fieldName = terrain_data.name
      root = "Graphics/Battlebacks/"
      @sprites["battle_bg"].setBitmap("#{root}/#{fieldName + "_bg"}".downcase) 
      @sprites["base_0"].setBitmap("#{root}/#{fieldName + "_base0"}".downcase) # enemy base
      @sprites["base_1"].setBitmap("#{root}/#{fieldName + "_base1"}".downcase) # player base
     end 
  end
end