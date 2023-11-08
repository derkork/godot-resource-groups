@tool

var _include_regexes:Array[RegEx]
var _exclude_regexes:Array[RegEx]

func _init(base_folder:String, include_patterns:Array[String], exclude_patterns:Array[String]):
	# compile the include and exclude patterns to regular expressions, so we don't
	# have to do it for each file
	_include_regexes = []
	_exclude_regexes = []
	

	for pattern in include_patterns:
		if pattern == "" or pattern == null:
			continue
		_include_regexes.append(_compile_pattern(base_folder, pattern))

	for pattern in exclude_patterns:
		if pattern == "" or pattern == null:
			continue
		_exclude_regexes.append(_compile_pattern(base_folder, pattern))



## Compiles the given pattern to a regular expression.
func _compile_pattern(base_folder:String, pattern:String) -> RegEx:
	# ** - matches zero or more characters (including "/")
	# * - matches zero or more characters (excluding "/")
	# ? - matches one character
	
	# we convert the pattern to a regular expression
	# ** becomes .*
	# * becomes [^/]* (any number of characters except /)
	# ? becomes [^/] (any character except /)
	# all other characters are escaped
	# the pattern is anchored at the beginning and end of the string
	# the pattern is case-sensitive

	var regex = "^" + _escape_string(base_folder) + "/"
	var i = 0
	var len = pattern.length()

	while i < len:
		var c = pattern[i]
		if c == "*":
			if i + 1 < len and pattern[i + 1] == "*":
				# ** - matches zero or more characters (including "/")
				regex += ".*"
				i += 2
			else:
				# * - matches zero or more characters (excluding "/")
				regex += "[^\\/]*"
				i += 1
		elif c == "?":
			# ? - matches one character
			regex += "[^\\/]"
			i += 1
		else:
			# escape all other characters
			regex += _escape_character(c)
			i += 1

	regex += "$"

	var  result = RegEx.new()
	result.compile(regex)
	return result


func _escape_string(c:String) -> String:
	var result = ""
	for i in len(c):
		result += _escape_character(c[i])
	return result

## Escapes the given character for use in a regular expression. 
## No clue why this is not built-in.
func _escape_character(c:String) -> String:
	if c == "\\":
		return "\\\\"
	elif c == "^":
		return "\\^"
	elif c == "$":
		return "\\$"
	elif c == ".":
		return "\\."
	elif c == "|":
		return "\\|"
	elif c == "?":
		return "\\?"
	elif c == "*":
		return "\\*"
	elif c == "+":
		return "\\+"
	elif c == "(":
		return "\\("
	elif c == ")":
		return "\\)"
	elif c == "{":
		return "\\{"
	elif c == "}":
		return "\\}"
	elif c == "[":
		return "\\["
	elif c == "]":
		return "\\]"
	elif c == "/":
		return "\\/"
	else:
		return c


func matches(file:String) -> bool:
	# the group definition has a list of include and exclude patterns
	# if the list of include patterns is empty, all files match
	# any file that matches an exclude pattern is excluded
	# we allow * as a wildcard for a single path segment
	# we allow ** as a wildcard for multiple path segments

	if _include_regexes.size() > 0:
		var found = false
		# the file must match at least one include pattern
		for item in _include_regexes:
			if item.search(file) != null:
				found = true
				break
			
		if not found:
			return false

	# the file must not match any exclude pattern
	for item in _exclude_regexes:
		if item.search(file) != null:
			return false

	return true
