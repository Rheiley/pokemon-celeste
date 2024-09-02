def arnicaTownMerchant1
  setPrice(:SWEETAPPLE, 1000)
  setPrice(:TARTAPPLE, 1000)
  setPrice(:SYRUPYAPPLE, 1500)
  pbPokemonMart([
    :SWEETAPPLE,
    :TARTAPPLE,
    :SYRUPYAPPLE
  ], 
  speech = "Welcome! I sell fresh produce!", 
  cantsell = true)
end