require 'gosu'

class Window < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "---=== ASTEROID STORM ===---"
    @background_image = Gosu::Image.new(self, "stars.png", true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    start_new_game
  end
  
  def start_new_game
    @hero = Hero.new(self)
    @laser = Laser.new(self, @hero)
    @asteroids = 5.times.map {Asteroid.new(self, @laser, @hero)}
    @running = true
  end
  
  def update
    if @running
      if button_down? Gosu::Button::KbRight
        @hero.move_forward
      end
  
      if button_down? Gosu::Button::KbLeft
        @hero.move_back
      end
  
      if button_down? Gosu::Button::KbUp
        @hero.move_up
      end
  
      if button_down? Gosu::Button::KbDown
        @hero.move_down
      end
         
      if button_down? Gosu::Button::KbSpace
        @laser.shoot
      end
      
      @laser.update
      @asteroids.each {|asteroid| asteroid.update}
      
      if @hero.hit_by?(@asteroids)
        @running = false
      end
    else
      if button_down? Gosu::Button::KbEscape
        start_new_game
      end
    end  
  end
  
  def draw
    @background_image.draw(0, 0, 0)
    @hero.draw
    @laser.draw
    @asteroids.each {|asteroid| asteroid.draw}
    @font.draw("Score: #{@hero.score}", 10, 10, 3, 1.0, 1.0, 0xffffff00)
  end
end 

class Hero
  attr_reader :x, :y, :score
  
  def initialize(window)
    @window = window
    @icon = Gosu::Image.new(@window, "spaceship.png", true)
    @x = 100
    @y = 215
    @score = 0
  end
  
  def add_score
    @score = @score + 10
  end
  
  def move_forward
    @x = @x + 5
    if @x > @window.width - @icon.width
      @x = @window.width - @icon.width
    end
  end
  
  def move_back
    @x = @x - 5
    if @x < 0
      @x = 0
    end
  end

  def move_up
    @y = @y - 5
    if @y < 0
      @y = 0
    end
  end

  def move_down
    @y = @y + 5
    if @y > @window.height - @icon.height
      @y = @window.height - @icon.height
    end
  end 
  
  def draw
    @icon.draw(@x, @y, 2)
  end
  
  def hit_by?(asteroids)
    asteroids.any? {|asteroid| Gosu::distance(@x, @y, asteroid.x, asteroid.y) < 50} 
  end  
end

class Asteroid
  attr_reader :x, :y
  
  def initialize(window, laser, hero)
    @window = window
    @laser = laser
    @hero = hero
    @icon = Gosu::Image.new(@window, "asteroid.png", true)
    @x = @window.width + rand(1000)
    @y = rand(@window.height - @icon.height)
    @speed = 3 + rand(5)
    @hits = 0
  end  
  
  def hit_by_laser?
    @laser.shooting && Gosu::distance(@x, @y, @laser.x, @laser.y) < 50
  end
  
  def update
    if hit_by_laser?
      @hits = @hits + 1
    end
    
    @x = @x - @speed
    
    if @x < -@icon.width || @hits >= 7
      @x = @window.width
      @y = rand(@window.height - @icon.height)
      @speed = 3 + rand(5)
      @hits = 0
      @hero.add_score
    end
  end

  def draw
    @icon.draw(@x, @y, 2)
  end  
end

class Laser
  attr_reader :x, :y, :shooting
  
  def initialize(window, hero)
    @window = window
    @hero = hero
    @icon = Gosu::Image.new(@window, "laser.png", true)
    laser_home
    @shooting = false
  end
  
  def shoot
    @shooting = true
  end
  
  def laser_home
    @x = @hero.x + 46
    @y = @hero.y + 3
  end
  
  def update
    if @shooting
      @x = @x + 30
      if @x > @window.width
        @shooting = false
      end
    else
      laser_home
    end
  end
  
  def draw
    @icon.draw(@x, @y, 1)
  end
end

window = Window.new
window.show