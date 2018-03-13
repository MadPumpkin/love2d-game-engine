require ('engine.core.AABB')
require ('engine.core.Vector')

require ('engine.core.utilities')


GraphGrammar = {}
GraphGrammar.__index = GraphGrammar

function GraphGrammar:create()
  local grammar = {
    symbols = {},
    productions = {},
    stop_condition = function() return true end
  }
  setmetatable(grammar, self)
  self.__index = self

  return grammar
end

function GraphGrammar:isValidSymbol(symbol)
  return self.symbols[symbol] ~= nil
end

function GraphGrammar:isTerminalSymbol(symbol)
  if self:isValidSymbol(symbol) then
    return #self.productions[symbol] < 1
  end
end

function GraphGrammar:containsSymbol(symbol, input_string)
  return symbol:match(input_string)
end

function GraphGrammar:addSymbol(symbol)
  self.symbols[symbol] = symbol
  self.productions[symbol] = {}
end

function GraphGrammar:setStopCondition(stop_condition)
  self.stop_condition = stop_condition
end

function GraphGrammar:addProduction(symbol, production)
  if self:isValidSymbol(symbol) then
    self.productions[symbol][#self.productions[symbol]+1] = production
  end
end

function GraphGrammar:getProductionFor(symbol)
  if self:isValidSymbol(symbol) then
    if self:isTerminalSymbol(symbol) then
      return symbol
    end
    local option = 1
    if #self.productions[symbol] > 1 then
      option = love.math.random(#self.productions[symbol])
    end
    return self.productions[symbol][option]
  end
  return ''
end

function GraphGrammar:getNextProduction(input_string)
  local result_string = ''
  for i = 1, #input_string do
    local c = input_string:sub(i, i)
    result_string = result_string .. self:getProductionFor(c)
  end
  return result_string
end

function GraphGrammar:getNthProduction(n, input_string)
  local result_string = input_string
  for i=1,n do
    result_string = self:getNextProduction(result_string)
  end
  return result_string
end

function GraphGrammar:stripNonTerminalSymbols(input_string)
  local result_string = ''
  for i = 1, #input_string do
    local c = input_string:sub(i, i)
    if self:isTerminalSymbol(c) then
      result_string = result_string .. c
    end
  end
  return result_string
end

function GraphGrammar:getWithSymbolProductions(symbol, input_string)
  local result_string = ''
  for i = 1, #input_string do
    local c = input_string:sub(i, i)
    if symbol == c then
      result_string = result_string .. self:getProductionFor(c)
    else
      result_string = result_string .. c
    end
  end
  return result_string
end

function GraphGrammar:execute(input_string)
  local result_string = input_string
  local stop_condition_met = false
  while not stop_condition_met do
    result_string = self:getNextProduction(result_string)
    stop_condition_met = self:stop_condition(result_string)
  end
  return result_string
end
