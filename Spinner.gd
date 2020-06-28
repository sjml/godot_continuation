extends ColorRect

# just constantly changes the color of this rect so we can tell when
#  the game is hitching

var colors = [Color(1, 1, 1), Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1)]
var colorIndex = 0
const maxColorTime = 1.0
var colorTimer = -1.0
var nextColor: Color
var currColor: Color

func _ready() -> void:
    colorTimer = 0.0
    currColor = colors[0]
    nextColor = colors[1]

func _process(delta: float) -> void:
    colorTimer += delta
    color = lerp(currColor, nextColor, colorTimer / maxColorTime)

    if colorTimer >= maxColorTime:
        colorTimer = 0.0
        colorIndex += 1
        if colorIndex >= colors.size():
            colorIndex = 0
        currColor = colors[colorIndex]
        if colorIndex+1 < colors.size():
            nextColor = colors[colorIndex+1]
        else:
            nextColor = colors[0]
