extends Control

const alphabet : Array = ['А','Б','В','Г','Д','Е','Ж','З','И','Й','К','Л','М','Н','О','П','Р','С','Т','У','Ф','Х','Ц','Ч','Ш','Щ','Ъ','Ь','Ю','Я']
var regex : RegEx = RegEx.new()

func shift_array(arr: Array, shift) -> Array:
	var shifted_array = arr
	for x in range(0, shift):
		var first_element = shifted_array[0]
		var rest_of_array = shifted_array.slice(1,len(shifted_array))
		shifted_array = rest_of_array + [first_element]
	return shifted_array


func get_vigenere_table() -> Array[Array]:
	var vigenere_table : Array[Array]
	for i in range(0,len(alphabet)):
		vigenere_table.append(alphabet)
		vigenere_table[i] = shift_array(vigenere_table[i], i)
	return vigenere_table


func decrypt_vigener_cypher(message : String, keyword : String, vigener_table : Array[Array]) -> String:
	# EQUALIZE LENGTH AND STRIP NON-ALPHABETIC
	message = strip_non_alphabetic(message)
	keyword = keyword.repeat(len(message)/len(keyword)).to_upper()
	keyword += keyword.substr(0,len(message)%len(keyword))
	
	var decrypted : String = ""
	for i in range(0, len(message)):
		var yCord = alphabet.find(keyword[i])
		var xCord
		for x in range(0, len(alphabet)):
			if message[i] == vigener_table[x][yCord]:
				xCord = x
		decrypted += vigener_table[xCord][0]
	return decrypted;


func encrypt_vigener_cypher(message : String, keyword : String, vigener_table: Array[Array]) -> String:
	# EQUALIZE LENGTH AND STRIP NON-ALPHABETIC
	message = strip_non_alphabetic(message)
	keyword = keyword.repeat(len(message)/len(keyword)).to_upper()
	keyword += keyword.substr(0,len(message)%len(keyword))
	
	var encrypted : String = ""
	# FIND CORDS
	for i in range(0, len(message)):
		var xCord = alphabet.find(message[i])
		var yCord = alphabet.find(keyword[i])
		encrypted += vigener_table[xCord][yCord]
		
	return encrypted


func strip_non_alphabetic(message : String) -> String:
	regex.compile("[^А-Яа-я]")
	return regex.sub(message,"", true).to_upper()


func _on_button_pressed():
	# GET TEXT
	var message = %MessageField.text
	var keyword = %KeywordField.text
	# ERROR HANDLING
	if(len(strip_non_alphabetic(message))==0):
		%ErrorDialog.visible = true
		%ErrorDialog.dialog_text = "Съобщението е невалидно."
		return 1
	elif(len(strip_non_alphabetic(keyword))==0):
		%ErrorDialog.visible = true
		%ErrorDialog.dialog_text = "Ключовата дума е невалидна."
		return 1
	elif(regex.search(keyword)):
		%ErrorDialog.dialog_text = "Ключовата дума не трябва да съдържа \nинтервали или препинателни знаци."
		%ErrorDialog.visible = true
		return 1
	match %CipherMethod.selected:
		0:
			vigenere_cipher(message, keyword)
		1:
			%Method.set_item_disabled(1, true)
			transposition_cipher(message, keyword)


func encrypt_transposition_cypher(message : String, keyword : String) -> String:
	message = strip_non_alphabetic(message)
	keyword = strip_non_alphabetic(keyword)
	
	message = keyword + message
	# FUCK ARRAY
	var message_table : Array[Array]
	for i in range(0, len(message)/len(keyword)):
		message_table.append((Array) (message.substr(len(keyword)*i, len(keyword)).split()))
	if len(message)%len(keyword) != 0:
		message_table.append((Array) (message.substr(len(message)-len(message)%len(keyword), len(message)%len(keyword)).split()))
	
	# TRANSPOSE ARRAY
	var message_colonised = transpose_array(message_table, keyword)
	message_colonised.sort()
	message_colonised = remove_first(message_colonised)
	return join_the_array(message_colonised)


func join_the_array(arr):
	var result = ""
	for row in arr:
		for elem in row:
			if elem != null:
				result += str(elem)
	return result


func remove_first(arr):
	for row in arr:
		row.remove_at(0)
	return arr


func transpose_array(arr: Array, keyword : String) -> Array:
	var max_row_length = len(keyword)
	var transposed_array = []

	for col_idx in range(max_row_length):
		var new_row = []

		for row in arr:
			if col_idx < row.size():
				new_row.append(row[col_idx])
			else:
				new_row.append(null)

		transposed_array.append(new_row)

	return transposed_array


func decrypt_transposition_cypher(message: String, keyword : String) -> String:
	message = strip_non_alphabetic(message)
	keyword = strip_non_alphabetic(keyword)
	
	message = keyword + message
	return ""


func transposition_cipher(message: String, keyword : String) -> void:
	# CHOOSE ACTION
	match %Method.selected:
		0:
			var encrypted = encrypt_transposition_cypher(message, keyword)
			%Result.text = encrypted
		1:
			var decrypted = decrypt_transposition_cypher(message, keyword)
			%Result.text = decrypted


func vigenere_cipher(message : String, keyword : String) -> void:
	# GET VIGENERE TABLE
	var vigenere_table = get_vigenere_table()
	# CHOOSE ACTION
	match %Method.selected:
		0:
			var encrypted = encrypt_vigener_cypher(message, keyword, vigenere_table)
			%Result.text = encrypted
		1:
			var decrypted = decrypt_vigener_cypher(message, keyword, vigenere_table)
			%Result.text = decrypted


func _on_cipher_method_item_selected(index):
	match index:
		1:
			%Method.selected = 0
			%Method.set_item_disabled(1, true)
			%Button.text = "Шифриране"
			%Method.tooltip_text = "Дешифрирането на транспозиционен шифър не се поддържа към момента."
			%CipherMethod.tooltip_text = "Транспозиционният шифър разбърква буквите в съобщението."
		0:
			%Method.set_item_disabled(1, false)
			%Method.tooltip_text = ""
			%CipherMethod.tooltip_text = "Шифърът на Виженер заменя буквите в съобщението."


func _on_method_item_selected(index):
	match index:
		0: %Button.text = "Шифриране"
		1: %Button.text = "Дешифриране"
