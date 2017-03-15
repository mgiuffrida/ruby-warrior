Round = Struct.new(:killed_enemy, :attacked_enemy, :took_damage, :rested)

class Player
  def initialize()
    @went_backward = false
    @turned_around = false
    @max_health = 20
    @prev_health = @max_health
    @prev_enemy_health = -1
    @probable_archer_distance = nil
    @prev_round = nil
    @cur_round = nil

    @enemy_count = 2

    puts "Initializing with #{@enemy_count} enemies"
  end

  def walk!(warrior, direction)
    if @probable_archer_distance != nil
      # TODO: this assumes the archer is always "forward" from us.
      @probable_archer_distance += (direction == :backward ? 1 : -1)
    end
    warrior.walk!(direction)
  end

  def attack!(warrior)
    @cur_round.attacked_enemy = true
    @prev_enemy_health -= 5
    warrior.attack!(:forward)
  end

  def rest!(warrior)
    @cur_round.rested = true
    warrior.rest!
  end

  # amount of damage enemy will do before warrior kills it
  def damage_potential(warrior, enemy_health)
    distance = @probable_archer_distance 
    if distance == nil
      distance = 0
    end
    warrior_attack = 5
    enemy_attack = 3
    warrior_health = warrior.health
    while enemy_health > 0 && warrior_health > 0 do
      if distance == 0
        enemy_health -= warrior_attack
      else
        distance -= 1
      end

      if enemy_health > 0
        warrior_health -= enemy_attack
      end
    end
    return warrior.health - warrior_health
  end

  def update_last_round(warrior)
    @prev_round = @cur_round
    @cur_round = Round.new()

    if !@prev_round
      @prev_round = Round.new()
      return
    end

    if @prev_round.attacked_enemy
      if !warrior.feel(:forward).enemy?
        @prev_round.killed_enemy = true
        @enemy_count -= 1
      end
    end

    # Check damage status.
    expected_health = (
      @prev_health + (@prev_round.rested ? 0.1 * @max_health : 0))
    if warrior.health < expected_health
      @prev_round.took_damage = true
    end
    @prev_health = warrior.health
  end

  def play_turn(warrior)
    update_last_round(warrior)

    # Rescue a captive in front of us.
    if warrior.feel(:forward).captive?
      warrior.rescue!(:forward)
      return
    end

    # Decide whether to retreat.
    if @prev_round.took_damage
      # Survivable?
      if warrior.feel(:forward).enemy?
        @probable_archer_distance = nil
      else
        # Assume archer has a range of 2...
        if @probable_archer_distance == nil
          @probable_archer_distance = 2
        end
      end

      # First time taking damage from this enemy?
      if @prev_enemy_health < 0
        if warrior.feel(:forward).enemy?
          # Must be melee.
          @prev_enemy_health = 24
        else
          # Must be ranged.
          @prev_enemy_health = 7
        end
      end

      if (damage_potential(warrior, @prev_enemy_health) >= warrior.health)
        puts "previous enemy health: #{@prev_enemy_health}"
        puts "warrior.health: #{warrior.health}"
        # This is just a retreat, not a pivot.
        walk!(warrior, :backward)
        return
      end
    end

    if warrior.feel(:forward).enemy?
      if @prev_enemy_health == -1
        @prev_enemy_health = 24 # ??
      end
      attack!(warrior)
    else
      assume_enemy_health = @prev_enemy_health
      # If there's no previous enemy, assume the next one will be a sludge,
      # since we know we're not taking damage yet.
      # NOTE: buggy.
      if assume_enemy_health < 0
        assume_enemy_health = 24
      end

      if (@enemy_count > 0 &&
          damage_potential(warrior, assume_enemy_health) >= warrior.health)
        puts ("resting: assume_enemy_health = #{assume_enemy_health}, " +
              "probable_archer_distance = #{@probable_archer_distance}")
        if @prev_round.killed_enemy
          # An archer could already be in range (level 6).
          # TODO: depending on what future levels look like, it may be worth
          # spending this turn on a rest anyway, and retreating if we get shot.
          # TODO: fails level 4, because we try to retreat into the wall.
          walk!(warrior, :backward)
        else
          rest!(warrior)
        end
      else
        if @turned_around
          if warrior.feel(:forward).wall?
            @turned_around = false
            warrior.pivot!(:backward)
            #walk!(warrior, @facing)
          else
            walk!(warrior, :forward)
          end
        elsif !@went_backward 
          @went_backward = true
          if warrior.feel(:backward).wall?
            walk!(warrior, :forward)
          else
            @turned_around = true
            warrior.pivot!(:backward)
            #walk!(warrior, :backward)
          end
        else
          walk!(warrior, :forward)
        end
      end
    end
  end
end
