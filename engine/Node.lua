local Functional = require 'engine.core.Functional'
local ObjectOriented = require 'engine.core.ObjectOriented'


local Node = ObjectOriented.new('Node')
Node.subnodes = {}
Node.inheritance_test = {false, true, false}
Node.subnodes[#Node.subnodes+1] = "Every node should have this subnode"

A = Node()
A.inheritance_test = {true, false}
A.subnodes[#A.subnodes+1] = "A subnode goes here and I hope B subnode doesn't"

NodeType2 = ObjectOriented.subclass(Node, 'MagicNodeB')
B = NodeType2()
B.test_success = A.inheritance_test
B.subnodes[#B.subnodes+1] = "B subnodes go here..... ONLY"
B.asdf = 3
B.assdf = 3
B.aksdf = 3

return {
  A.subnodes,
  B.subnodes,
}
