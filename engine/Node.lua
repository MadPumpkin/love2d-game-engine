local Functional = require 'engine.core.Functional'
local ObjectOriented = require 'engine.core.ObjectOriented'


local Node = ObjectOriented.new('Node')
Node.subnodes = {}

A = Node()
A.inheritance_test = true

B = ObjectOriented.subclass(A, 'MagicNodeB')
B.test_success = B.inheritance_test
B.asdf = 3
B.assdf = 3
B.aksdf = 3

return B.test_succesasdfsdfsdf
