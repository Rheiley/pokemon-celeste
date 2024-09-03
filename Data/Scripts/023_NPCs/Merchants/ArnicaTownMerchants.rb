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

def arnicaTownMerchant2
  setPrice(:ORANBERRY, 300)
  setPrice(:PECHABERRY, 300)
  setPrice(:RAWSTBERRY, 300)
  setPrice(:CHERIBERRY, 300)
  setPrice(:CHESTOBERRY, 300)

  pbPokemonMart([
    :ORANBERRY,
    :PECHABERRY,
    :RAWSTBERRY,
    :CHERIBERRY,
    :CHESTOBERRY
  ], 
  speech = "Get your berries here!", 
  cantsell = true)
end

def arnicaTownMerchant3
  setPrice(:FRESHWATER, 500)
  setPrice(:SODAPOP, 600)
  setPrice(:LEMONADE, 750)

  pbPokemonMart([
    :FRESHWATER,
    :SODAPOP,
    :LEMONADE
  ], 
  speech = "Cold drinks for sale here!", 
  cantsell = true)
end


