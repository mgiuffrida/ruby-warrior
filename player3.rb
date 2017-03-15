class Player
  # amount of damage enemy will do before warrior kills it
  def damage_potential(warrior, enemy_health)
    warrior_attack = 5
    enemy_attack = 3
    warrior_health = warrior.health
    while enemy_health > 0 and warrior_health > 0 do
      enemy_health -= warrior_attack
      if enemy_health > 0
        warrior_health -= enemy_attack
      end
    end
    warrior.health - warrior_health
  end

  def play_turn(warrior)
    if warrior.feel.empty?
      if warrior.health < 20 and
          damage_potential(warrior, 12) >= warrior.health
        warrior.rest!
      else
        warrior.walk!
      end
    else
      warrior.attack!
    end
  end
end
