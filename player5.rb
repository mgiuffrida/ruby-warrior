class Player
  def initialize()
    @enemy_count = 3
    @max_health = 20
    @prev_health = @max_health
    @resting = false
    puts "Initializing with #{@enemy_count} enemies"
  end

  # amount of damage enemy will do before warrior kills it
  def damage_potential(warrior, enemy_health)
    warrior_attack = 5
    enemy_attack = 3
    warrior_health = warrior.health
    while enemy_health > 0 && warrior_health > 0 do
      enemy_health -= warrior_attack
      if enemy_health > 0
        warrior_health -= enemy_attack
      end
    end
    warrior.health - warrior_health
  end

  def attack!(warrior)
    @attacking = true
    warrior.attack!
  end

  def play_turn(warrior)
    # Check damage status
    expected_health = @prev_health + (@resting ? 0.1 * @max_health : 0)
    if warrior.health < expected_health
        taking_damage = true
    end
    @prev_health = warrior.health

    if !warrior.feel.empty? and !warrior.feel.captive?
      attack!(warrior)
      return
    end

    # Update attacking state and enemy count
    if @attacking
      @attacking = false
      @enemy_count -= 1
    end

    if warrior.feel.captive?
      warrior.rescue!
      return
    end

    if (@enemy_count > 0 && warrior.health < 20 &&
        damage_potential(warrior, 24) >= warrior.health &&
        !taking_damage)
      warrior.rest!
    else
      warrior.walk!
    end
  end
end
