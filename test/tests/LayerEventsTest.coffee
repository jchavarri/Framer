simulate = require "simulate"

describe "LayerEvents", ->

	describe "Events", ->

		it "should set pointer events", ->

			layer = new Layer()

			layer.ignoreEvents = false
			layer.style["pointerEvents"].should.equal "auto"

			layer.ignoreEvents = true
			layer.style["pointerEvents"].should.equal "none"

		it "should not listen to events by default", ->
			
			layer = new Layer()
			layer.ignoreEvents.should.equal true
			layer.style["pointerEvents"].should.equal "none"


		it "should not listen to events until a listener is added", ->
			
			layer = new Layer()
			layer.ignoreEvents.should.equal true

			layer.on Events.Click, ->
				console.log "hello"

			layer.ignoreEvents.should.equal false

		it "should modify the event scope", (callback) ->

			myLayer = new Layer()

			myLayer.on "click", (event, layer) ->
				@id.should.equal myLayer.id
				layer.id.should.equal myLayer.id
				callback()

			simulate.click myLayer._element


		it "should modify the event scope for once", (callback) ->

			myLayer = new Layer()

			myLayer.once "click", (event, layer) ->
				@id.should.equal myLayer.id
				layer.id.should.equal myLayer.id
				callback()

			simulate.click myLayer._element

		it "should remove events", ->

			layer = new Layer
			
			clickCount = 0

			handler = ->
				clickCount++

			layer.on "test", handler

			layer.emit "test"
			clickCount.should.equal 1

			layer.off "test", handler

			layer.emit "test"
			clickCount.should.equal 1


		it "should only run an event once", ->
			
			layerA = new Layer
			count = 0

			layerA.once "hello", (layer) ->
				count++
				layerA.should.equal layer

			for i in [0..10]
				layerA.emit("hello")

			count.should.equal 1

		it "should modify scope for draggable events", (callback) ->
			
			layerA = new Layer
			layerA.draggable.enabled = true
			layerA.on "test", (args...) ->
				@id.should.equal(layerA.id)
				callback()

			layerA.draggable.emit("test", {})

		it "should list all events", ->
			layerA = new Layer
			handler = -> console.log "hello"
			layerA.on("test", handler)
			layerA.listeners("test").length.should.equal 1

		it "should remove all events", ->
			layerA = new Layer
			handler = -> console.log "hello"
			layerA.on("test", handler)
			layerA.removeAllListeners("test")
			layerA.listeners("test").length.should.equal 0

		it "should add and clean up dom events", ->
			layerA = new Layer
			handler = -> console.log "hello"

			layerA.on(Events.Click, handler)
			layerA.on(Events.Click, handler)
			layerA.on(Events.Click, handler)
			layerA.on(Events.Click, handler)

			# But never more then one
			layerA._domEventManager.listeners(Events.Click).length.should.equal(1)

			layerA.removeAllListeners(Events.Click)

			# And on removal, we should get rid of the dom event
			layerA._domEventManager.listeners(Events.Click).length.should.equal(0)

		it "should work with event helpers", (done) ->

			layer = new Layer

			layer.onMouseOver (event, aLayer) ->
				aLayer.should.equal(layer)
				@should.equal(layer)
				done()

			simulate.mouseover(layer._element)

	describe "Gesture events", ->

		it "should not be listened to until a listener is added", ->
			
			layer = new Layer()
			layer.ignoreEvents.should.equal true

			layer.on Events.Pinch, ->
				console.log "hello"

			layer.ignoreEvents.should.equal false

		it "should call the handler when added and do nothing when removed", ->

			layer = new Layer
			
			pinchCount = 0

			handler = ->
				pinchCount++

			layer.on Events.Pinch, handler

			layer.emit Events.Pinch
			pinchCount.should.equal 1

			layer.off Events.Pinch, handler

			layer.emit Events.Pinch
			pinchCount.should.equal 1


		it "should only run once when using 'once'", ->
			
			layerA = new Layer
			count = 0

			layerA.once Events.Pinch, (layer) ->
				count++
				layerA.should.equal layer

			for i in [0..10]
				layerA.emit(Events.Pinch)

			count.should.equal 1

		it "should list all gesture events", ->
			layerA = new Layer
			handler = -> console.log "hello"
			layerA.on(Events.Pinch, handler)
			layerA.listeners(Events.Pinch).length.should.equal 1

		it "should remove all gesture events", ->
			layerA = new Layer
			handler = -> console.log "hello"
			layerA.on(Events.Pinch, handler)
			layerA.removeAllListeners(Events.Pinch)
			layerA.listeners(Events.Pinch).length.should.equal 0