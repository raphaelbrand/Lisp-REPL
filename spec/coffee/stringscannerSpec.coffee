describe 'tokenizer', ->
  
  it 'should add whitespaces around closing brackets', ->
    tokenized = tokenize '(+ 1 1 (+ 1 1))'
    expect(tokenized).toEqual ['(', '+', '1', '1', '(', '+', '1', '1', ')', ')']
    
  it 'should add whitespaces around opening brackets', ->
    tokenized = tokenize '(+ 1 1(+ 1 1) )'
    expect(tokenized).toEqual ['(', '+', '1', '1', '(', '+', '1', '1', ')', ')']
  
  it 'should trim tokens and remove unnecessary white space', ->
    tokenized = tokenize '(+     1 1   ( +   1  1)   )'
    expect(tokenized).toEqual ['(', '+', '1', '1', '(', '+', '1', '1', ')', ')']
  
  it 'should recognize a quoted input', ->
    tokenized = tokenize '\'(a b c)'
    expect(tokenized).toEqual ['\'(', 'a', 'b', 'c', ')']
    
  it 'should recognize a quoted input with extra whitespaces', ->
    tokenized = tokenize '\'   (a b c)'
    expect(tokenized).toEqual ['\'(', 'a', 'b', 'c', ')']

  it 'should recognize a list', ->
    tokenized = tokenize '\'(1 2)'
    expect(tokenized).toEqual ['\'(', '1', '2', ')']
  
    
describe 'value parser', ->
  
  it 'should parse boolean true', ->
    parsed = parseValue 'true'
    expect(parsed).toBe Lisp.True
    
  it 'should parse boolean false', ->
    parsed = parseValue 'false'
    expect(parsed).toBe Lisp.False
    
  it 'should parse an integer', ->
    parsed = parseValue '1'
    expect(parsed).toEqual new Lisp.Number 1
    
  it 'should parse a float', ->
    parsed = parseValue 1.1
    expect(parsed).toEqual new Lisp.Number 1.1
    
  it 'should parse symbol', ->
    parsed = parseValue "'abc"
    expect(parsed).toEqual new Lisp.Symbol 'abc'
    
  it 'should recognize variables', ->
    tokens = ['+', '-', 'a', 'b']
    parsed = (parseValue token for token in tokens)
    for procedure in parsed
      expect(procedure.type).toEqual 'Variable'
  
    
describe 'token parser', ->
  
  it 'should recognize a nested expression', ->
    tokens = ['(', '+', '1', '(', '+', '1', '1', ')', ')']
    parsed = parseTokens tokens
    expected = [new Lisp.Var('+'), new Lisp.Number(1),
                [new Lisp.Var('+'), new Lisp.Number(1), new Lisp.Number(1)]]
    expect(parsed).toEqual expected
  
  it 'should recognize a list', ->
    tokens = ['\'(', '1', '2', ')']
    parsed = parseTokens tokens
    expected = new Lisp.Cons(new Lisp.Number(1), new Lisp.Cons(
                 new Lisp.Number(2), Lisp.Nil))
    expect(parsed).toEqual expected

describe 'list builder', ->
  
  it 'should build a nested list', ->
    values = [1,2,3]
    list = buildList values
    expected = new Lisp.Cons(1,new Lisp.Cons(2,new Lisp.Cons(3, Lisp.Nil)))
    expect(list).toEqual expected