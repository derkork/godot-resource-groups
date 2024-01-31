class_name ResourceGroupBackgroundLoader

var _open:Array[String] = []
var _callback:Callable
var _cancelled:bool = false
var _total:int = 0
var _finished:int = 0


## A loaded resource. This will be given as argument
## to the callback function
class ResourceLoadingInfo:
	## Whether loading of this resource was successful
	var success:bool
	## The path from which the resource was loaded
	var path:String
	## The loaded resource. Is null when success is false
	var resource:Resource
	## The overall progress of the background loading, can
	## be used to drive a progress indicator
	var progress:float
	## Whether this has been the last resource
	## of the 
	var last:bool

## Ctor. Takes an array of paths to load.
func _init(paths:Array[String], callback:Callable):
	_callback = callback
	
	# copy all into the open array and reverse the order
	# so we can use the array as a stack
	_open.append_array(paths)
	_open.reverse()
	
	# make note of the total amount of things
	_total = _open.size()
	
	# start loading
	_call_deferred(_next)
	
	
## Cancels the currently running background loading process
## as soon as possible. If the process is already finished, 
## nothing will happen. This function will immediately return.
func cancel():
	_cancelled = true

	
## Checks if the background loading process is done.
func is_done() -> bool:
	return _open.is_empty() or _cancelled

	
## Looks like call_deferred does not work properly when not in a node
## context (it doesn't seem to defer there...), so we roll our own here.
func _call_deferred(callable:Callable, args:Array = []):
	await Engine.get_main_loop().process_frame
	callable.callv(args)
		
## Starts the loading process for the next file in background.	
func _next():
	# if we're done or the process was cancelled, stop it here.
	if _open.is_empty() or _cancelled:
		return

	# fetch the next path and ask the resource loader to load it.
	var path = _open.pop_back()
	var result = ResourceLoader.load_threaded_request(path)
	if result != OK:
		push_warning("Unable to load path ", path , " return code ", result)
		

	_call_deferred(_fetch, [path])	

## Tries to fetch a file currently being loaded in background.	
func _fetch(path:String):
	var status = ResourceLoader.load_threaded_get_status(path)
	match (status):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_warning("Loading resource at ", path , " failed. Invalid resource. Ignoring and moving on.")	
			_failed(path)
			
		ResourceLoader.THREAD_LOAD_FAILED:
			push_warning("Loading resource at ", path , " failed. Ignoring and moving on.")	
			_failed(path)
			
		# if its ready, ship it to the callback and move on
		ResourceLoader.THREAD_LOAD_LOADED:
			var resource = ResourceLoader.load_threaded_get(path)
			_succeeded(path, resource)

		# we're still loading, so try again next frame
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_call_deferred(_fetch, [path])		

		
# Called when a path loading ultimately failed. Informs the callback
# and moves on.
func _failed(path:String):
	_finished += 1
	_call_callback(false, path, null)
	_call_deferred(_next)

## Called when a path loading ultimately succeeded. Informs the callback
## and moves on.
func _succeeded(path:String, resource:Resource):
	_finished += 1
	_call_callback(true, path, resource)
	_call_deferred(_next)
	
## Called when an operation is finished. Will invoke the callback.
func _call_callback(success:bool, path:String, resource:Resource):
	# don't call the callback anymore if the process was cancelled
	if _cancelled:
		return
		
	var progress:float = 1.0 if _total == 0 else float(_finished) / float(_total)
	
	var result = ResourceLoadingInfo.new()
	result.success = success
	result.path = path
	result.resource = resource
	result.progress = progress
	result.last = _open.is_empty()
	
	_callback.call(result)
