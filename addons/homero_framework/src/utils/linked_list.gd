class_name LinkedList
extends RefCounted

var front: LinkedListItem = null
var back: LinkedListItem = null
var length: int = 0


func size() -> int:
	return length


func as_array() -> Array:
	var return_array: Array = []
	var next: LinkedListItem = front
	while next:
		return_array.push_back(next.data)
		next = next.next
	return return_array


func get_value(index:int):
	if index < 0 || index >= length:
		return null
	
	var half: int = length/2
	var item: LinkedListItem
	if index < half:
		item = front
		var count:int = 0
		while index != count:
			item = item.next
			count += 1
	else:
		item = back
		var count:int = length-1
		while index != count:
			item = item.previous
			count -= 1
	return item.data


func front_data():
	return front.data


func back_data():
	return back.data


func push_front(data) -> void:
	if length == 0:
		front = LinkedListItem.new(data)
		back = front
	else:
		var new_head = LinkedListItem.new(data)
		new_head.link(front)
		front = new_head
	length += 1


func pop_front():
	if length == 0:
		return null
	else:
		if front == back:
			back = null
		var result = front.data
		front = front.next
		if front != null:
			front.previous = null
		length -= 1
		return result


func push_back(data) -> void:
	if length == 0:
		front = LinkedListItem.new(data)
		back = front
	else:
		var new_tail = LinkedListItem.new(data)
		back.link(new_tail)
		back = new_tail
	length += 1


func pop_back():
	if length == 0:
		return null
	else:
		if front == back:
			front = null
		var result = back.data
		back = back.previous
		if back != null:
			back.next = null
		length -= 1
		return result


func unlink(item: LinkedListItem) -> void:
	item.unlink()
	length -= 1
	if length == 0:
		front = null
		back = null
	else:
		if front == item:
			if front == back:
				back = null
			front = front.next
			if front != null:
				front.previous = null
		if back == item:
			if front == back:
				front = null
			back = back.previous
			if back != null:
				back.next = null


func destroy() -> void:
	while length > 0:
		pop_front()




class LinkedListItem:
	extends RefCounted
	
	var next: LinkedListItem = null
	var previous: LinkedListItem = null
	var data
	
	
	func _init(p_data) -> void:
		data = p_data
	
	
	func link(other: LinkedListItem) -> void:
		other.previous = self
		next = other
	
	
	func unlink() -> void:
		if previous:
			previous.next = next
		if next:
			next.previous = previous
