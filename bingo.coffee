# 
# Entry for Yahoo Bingo Contest as part of Node Summit
# @djenryte
#

io = require 'socket.io-client' 

socket = io.connect('ws://yahoobingo.herokuapp.com')

LetterToRowIndexMapping = (letter)->
	switch letter
		when 'B' then return 0
		when 'I' then return 1
		when 'N' then return 2
		when 'G' then return 3
		when 'O' then return 4
		else return null

socket.on 'connect', ->
	socket.emit	'register', 
		name: 'Henry Bow'
		email: 'hbow27@gmail.com'
		url: 'https://github.com/djenryte/bingo'
	
	# intialize 5 rows, 5 colums, and 2 diagonals to 5. Decrement from the related set
	# as a card that is drawn is contained within our bingo board
	rowSet = [5,5,5,5,5]
	columnSet = [5,5,5,5,5]
	diagonalSet = [5,5]

	socket.on 'card', (payload)=>
		console.log 'data', payload
		@slots = payload.slots

	socket.on 'number', (bingoNumber)=>
		console.log 'data', bingoNumber
		for index in [0..4]
			if @slots[bingoNumber[0]][index] is parseInt bingoNumber.substring(1)
				console.log 'got'
				columnIndex = LetterToRowIndexMapping bingoNumber[0]
				
				--rowSet[index]
				--columnSet[columnIndex]

				# decrement needed cards for '\' diagonal
				if index is columnIndex
					console.log 'dia1', [index, columnIndex]
					--diagonalSet[0]
				# decrement needed cards for '/' diagonal
				if index + columnIndex is 4
					console.log 'dia2', [index, columnIndex]
					--diagonalSet[1]
				
				if rowSet[index] is 0 or columnSet[columnIndex] is 0 or diagonalSet[0] is 0 or diagonalSet[1] is 0
					console.log 'bingo'
					socket.emit 'bingo'

				# remove from slots so that if the card is drawn again, our rows/columns/diagonals counters
				# are not affected
				@slots[bingoNumber[0]][index] = null

	socket.on 'win', (message)->
		console.log 'message', message
	socket.on 'lose', (message)->
		console.log 'message', message
	socket.on 'disconnect', ->
		console.log 'disconnect'


