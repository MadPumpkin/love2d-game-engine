local TypeNode = {}
TypeNode.__index = TypeNode

TypeNode.__next_public_id = 0
function TypeNode:__nextId()
  self.__next_public_id = self.__next_public_id + 1
  return self.__next_public_id
end

function TypeNode:new(table)

end
