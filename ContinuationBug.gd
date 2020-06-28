extends Control

onready var outputLabel = $OutputLabel
export(int) var frameBudgetMicroseconds = 10000
export(int) var nodeDelay = 1000
export(int) var treeDepth = 10

class TreeNode:
    var _leftChild: TreeNode = null
    var _rightChild: TreeNode = null
    var _depth: int = -1

    func _init(depth: int) -> void:
        _depth = depth

    func _hasChildren():
        if _leftChild or _rightChild:
            return true
        return false

func ExpensiveTreeFunction(node: TreeNode):
    if node._hasChildren():
        ExpensiveTreeFunction(node._leftChild)
        ExpensiveTreeFunction(node._rightChild)
        return

    OS.delay_usec(nodeDelay)


var _frameCount = 0
var _timer = 0
var _frameStartTimestamp = 0
var _frameElapsed = 0
var _continuation = null
var _isRunning = false

func _startFrameTimer():
    _timer += _frameElapsed
    _frameElapsed = 0
    _frameCount += 1
    _frameStartTimestamp = OS.get_ticks_usec()

func _checkFrameTimer() -> bool:
    _frameElapsed = OS.get_ticks_usec() - _frameStartTimestamp
    return _frameElapsed >= frameBudgetMicroseconds

func _process(_delta: float):
    if _isRunning and _continuation:
        _startFrameTimer()
        _continuation = _continuation.resume()
        if not _continuation:
            _isRunning = false
            outputLabel.text = "%.02f ms elapsed over %d frames" % [_timer / 1000.0, _frameCount]

func StartExpensiveFunction():
    _isRunning = true
    _frameCount = 0
    _timer = 0

    _startFrameTimer()
    _continuation = AmortizeExpensiveTreeFunction(fakeRoot)

func AmortizeExpensiveTreeFunction(node: TreeNode):
    if _checkFrameTimer():
        yield()

    if node._hasChildren():
        var leftAttempt = AmortizeExpensiveTreeFunction(node._leftChild)
        while (leftAttempt is GDScriptFunctionState):
            yield()
            leftAttempt = leftAttempt.resume()
        var rightAttempt = AmortizeExpensiveTreeFunction(node._rightChild)
        while (rightAttempt is GDScriptFunctionState):
            yield()
            rightAttempt = rightAttempt.resume()
        return

    OS.delay_usec(nodeDelay)





func BuildFakeTree(depth: int) -> TreeNode:
    var root = TreeNode.new(depth)

    if depth > 0:
        root._leftChild = BuildFakeTree(depth-1)
        root._rightChild = BuildFakeTree(depth-1)

    return root

var fakeRoot: TreeNode = null
func _ready() -> void:
    fakeRoot = BuildFakeTree(treeDepth)

func _on_ExpensiveFunctionBtn_pressed() -> void:
    var before = OS.get_ticks_usec()
    ExpensiveTreeFunction(fakeRoot)
    var after = OS.get_ticks_usec()
    outputLabel.text = "%.02f ms elapsed over 1 frame" % [(after-before) / 1000.0]

func _on_AmortizeExpensiveFunctionBtn_pressed() -> void:
    outputLabel.text = ""
    StartExpensiveFunction()
