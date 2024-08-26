def miniBossExeggutor
  setBattleRule("midbattleScript", {
    "RoundStartCommand_1_foe" => {
      "text" => "{1} awakened the dragon within!",
      "battlerStats" => [:ATTACK, 1, :DEFENSE, 1]
    }
  })
end