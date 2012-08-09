functions =
  'cons': (ast) ->
    "[#{compile ast[0]}, #{compile ast[1]}]"
  '+': (ast) ->
    "(#{ast.reduce (a,b) -> "#{compile a} + #{compile b}"})"
  '-': (ast) ->
    "(#{ast.reduce (a,b) -> "#{compile a} - #{compile b}"})"
  '*': (ast) ->
    "(#{ast.reduce (a,b) -> "#{compile a} * #{compile b}"})"
  '/': (ast) ->
    "(#{ast.reduce (a,b) -> "#{compile a} / #{compile b}"})"
  'eq?': (ast) ->
    "#{compile ast[0]} === #{compile ast[1]}"
  '<': (ast) ->
    "(#{compile ast[0]} < #{compile ast[1]})"
  '>': (ast) ->
    "(#{compile ast[0]} > #{compile ast[1]})"
  '>=': (ast) ->
    "(#{compile ast[0]} >= #{compile ast[1]})"
  '<=': (ast) ->
    "(#{compile ast[0]} <= #{compile ast[1]})"
  'not': (ast) ->
    "!(#{compile ast[0]})"
  'and': (ast) ->
    "(#{ast.reduce (a,b) -> "#{compile a} && #{compile b}"})"
  'or': (ast) ->
    "(#{ast.reduce (a,b) -> "#{compile a} || #{compile b}"})"
  'first': (ast) ->
    "#{compile ast[0]}[0]"
  'rest': (ast) ->
    "#{compile ast[0]}.slice(1)"
  'last': (ast) ->
    "#{compile ast[0]}.slice(-2)[0]"
  'define': (ast) ->
    if ast[0].type is 'JList'
      #alternative lambda syntax was used
      res = "var #{compile ast[0][0]} = function("
      res += ast[0][1..].reduce (a,b) -> "#{compile a}, #{compile b}"
      res += ') { '
      ast[1..].forEach (item, index, array) ->
        if index is array.length-1
          res += "return #{compile item};"
        else
          res += "#{compile item}; "
      res += ' };'
      res
    else
      "var #{compile ast[0]} = #{compile ast[1]};"
  'set!': (ast) ->
    "#{compile ast[0]} = #{compile ast[1]};"
  'lambda': (ast) ->
    "function(#{ast[0].reduce (a,b) -> "#{compile a}, #{compile b}"}) " +
      "{ " +
        "return #{compile ast[1]};" +
      " }"
  'begin': (ast) ->
    res = "(function() { "
    res += ast.reduce (a,b,i,c) ->
      if i is c.length-1
        "#{compile a}; return #{compile b};"
      else
        "#{compile a}; #{compile b}"
    res += " })();"
  'if': (ast) ->
    "(#{compile ast[0]}) ? #{compile ast[1]} : #{compile ast[2]}"
  'print': (ast) ->
    "console.log(#{compile ast[0]});"
  'let': (ast) ->
    res = "(function() { "
    ast[0].forEach (i) ->
      res += "var #{compile i[0]} = #{compile i[1]}; "
    res += "return #{compile ast[1]}; })()"
    res

buildArray = (cons) ->
  if cons.rest.type isnt 'Nil'
    "#{compile cons.first}, #{buildArray cons.rest}"
  else
    "#{compile cons.first}, #{compile cons.rest}"

compile = (ast) ->
  switch ast.type
    when 'JList'
      if ast[0].value of functions
        functions[ast[0].value](ast[1..])
      else
        rest = ast[1..]
        if rest.length is 1
          "#{compile ast[0]}(#{compile rest[0]});"
        else
          "#{compile ast[0]}(#{ast[1..].reduce (a,b) -> "#{compile a}, #{compile b}"});"
    when 'Symbol'
      ast.toString().slice 1
    when 'Boolean'
      ast.value.toString()
    when 'Quoted'
      if ast.value.type is 'Cons'
        "[#{buildArray ast.value}]"
      #javascript has no symbols, treat them like normal strings
      else if ast.value.type is 'Symbol'
        '"' + ast.value.value + '"'
      else
        compile ast.value
    when 'Nil'
      null
    else
      ast.toString()



# EXPORTS
window.Compiler =
  compile: compile