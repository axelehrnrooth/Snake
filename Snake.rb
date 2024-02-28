require 'ruby2d' #importerar det bibliotek som krävs för ruby 2d

set fps_cap: 10 #hastigheten på ormen
set title: "Snake X2000" #titeln på spelet
set width: 640 #spelskärmens bredd
set height: 480 #spelskärmens höjd
SQUARE_SIZE = 40 #storleken på varje enskild fyrkant
GRID_WIDTH = Window.width / SQUARE_SIZE #hur kvadraterna ska delas upp inom området
GRID_HEIGHT = Window.height / SQUARE_SIZE #hur kvadraterna ska delas upp inom området

#den här funktionen delar upp så att backgrunden har ett jämt antal kvadrater i sig och så att färgerna är varannan ljusblå och varannan mörkblå.
def load_background(color1, color2, cell_size)
  (0..(Window.width / cell_size)).each do |x|
    (0..(Window.height / cell_size)).each do |y|
      color = (x + y).even? ? color1 : color2
      Rectangle.new(x: x * cell_size, y: y * cell_size, width: cell_size, height: cell_size, color: color)
    end
  end
end

#Här skapar jag en klass för ormen
class Snake
  attr_writer :direction

  #definierar ormens startpostion, rikting den rör sig i samt om den växer eller inte
  def initialize
    @positions = [[2, 0], [2, 1], [2, 2], [2 ,3]]
    @direction = 'down'
    @growing = false
  end

  #Ritar ut ormen på skärmen genom att skapa en kvadrat för varje position
  def draw
    @positions.each do |position|
      Square.new(x: position[0] * SQUARE_SIZE, y: position[1] * SQUARE_SIZE, size: SQUARE_SIZE - 1, color: 'green')
    end
  end

  #funktionen som ändrar så ormen växer (när den växer bestäms i loopen)
  def grow
    @growing = true
  end

  #Flyttar ormen genom att ta bort den första positionen om den inte växer och lägger till nästa position baserat på rörelseriktningen innan flaggan för tillväxt återställs.
  def move
    if !@growing
      @positions.shift
    end

    @positions.push(next_position)
    @growing = false
  end

  #Funktionen som definierar hur omren styrs beroende på vilken tangent du trycker ner
  def can_change_direction_to?(new_direction)
    case @direction
    when 'up' then new_direction != 'down'
    when 'down' then new_direction != 'up'
    when 'left' then new_direction != 'right'
    when 'right' then new_direction != 'left'
    end
  end

  # Returnerar X kordinaten för ormens huvud
  def x
    head[0]
  end

  # Returnerar Y kordinaten för ormens huvud
  def y
    head[1]
  end

  # Beräknar nästa position för ormen beroende på dess aktuella riktning.
def next_position
    if @direction == 'down'
      new_coords(head[0], head[1] + 1)
    elsif @direction == 'up'
      new_coords(head[0], head[1] - 1)
    elsif @direction == 'left'
      new_coords(head[0] - 1, head[1])
    elsif @direction == 'right'
      new_coords(head[0] + 1, head[1])
    end
  end

  # Kollar om ormen åker in i sig själv
  def hit_itself?
    @positions.uniq.length != @positions.length
  end

  private

  # Beräknar dem nya kordinaterna får ormen baserat på dess kordinator och var på griden den är
  def new_coords(x, y)
    [x % GRID_WIDTH, y % GRID_HEIGHT]
  end
  # Returnerar positionen för ormens huvud
  def head
    @positions.last
  end
end

class Game
  # Definierar start värden för boll och om spelet är klart eller inte samt scoret
  def initialize
    @ball_x = 10
    @ball_y = 10
    @score = 0
    @finished = false
  end

  # Ritar ut "Bollen"
  def draw
    Square.new(x: @ball_x * SQUARE_SIZE, y: @ball_y * SQUARE_SIZE, size: SQUARE_SIZE, color: 'yellow')
    Text.new(text_message, color: 'black', x: 10, y: 10, size: 25, z: 1)
  end
  # Kontrollerar om ormen träffar bollen
  def snake_hit_ball?(x, y)
    @ball_x == x && @ball_y == y
  end

  #Funktionen som lägger till ett poäng och ger bollen en ny position om ormen träffar bollen
  def record_hit
    @score += 1
    @ball_x = rand(Window.width / SQUARE_SIZE)
    @ball_y = rand(Window.height / SQUARE_SIZE)
  end
 # Markerar om spelet är klart
  def finish
    @finished = true
  end
  # Returnerar värdet om spelet är klart eller inte
  def finished?
    @finished
  end

  private

  #En textsträng som informerar spelaren om spelets status och poäng. Om spelet är avslutat, meddelar funktionen spelaren om spelets slut och visar poängen. Om spelet inte är avslutat, visar det bara spelarens poäng.
  def text_message
    if finished?
      "Game over, ditt score va #{@score}. Tryck 'R' för att spela igen. "
    else
      "Score: #{@score}"
    end
  end
end

snake = Snake.new
game = Game.new

#Här börjar loopen
update do
  clear
  #Backgrunden definieras
  load_background('#63B7EE', '#C9E0FF', SQUARE_SIZE)

    #sålänge game.finished funktionen är false rör ormen sig
  unless game.finished?
    snake.move
  end
  #spel och orm klassrna målas ut
  snake.draw
  game.draw

  #Koden kollar hela tiden om bollen och ormen kolliderar, och gör dem det så blir ormen större och scoret höjs
  if game.snake_hit_ball?(snake.x, snake.y)
    game.record_hit
    snake.grow
  end

  #om funktionen snake.hit_itself? är true så är spelet slut
  if snake.hit_itself?
    game.finish
  end

end

# denhär koden hanterar tangenttryckningar, den gör det genom 2 if satser, om du trycker r efter att du dör startar spelet om. Och trycker du på piltageterna så ändras ormens riktning
on :key_down do |event|
  if ['up', 'down', 'left', 'right'].include?(event.key)
    if snake.can_change_direction_to?(event.key)
      snake.direction = event.key
    end
  end

  if game.finished? && event.key == 'r'
    snake = Snake.new
    game = Game.new
  end
end

show