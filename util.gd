class_name Util

static func swap(list, idx1, idx2):
	var temp = list[idx1]
	list[idx1] = list[idx2]
	list[idx2] = temp
	return list