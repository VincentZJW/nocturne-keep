class_name CurrencyWallet
extends Node

## Run-persistent wallet. A fresh process/new run starts at zero.

signal coins_changed(current: int, delta: int)
signal coins_added(amount: int, current: int)
signal coins_spent(amount: int, current: int)
signal insufficient_coins(required: int, current: int)

var current_coins: int = 0


func add_coins(amount: int) -> bool:
	if amount <= 0:
		return false
	current_coins += amount
	coins_changed.emit(current_coins, amount)
	coins_added.emit(amount, current_coins)
	return true


func can_afford(amount: int) -> bool:
	return amount >= 0 and current_coins >= amount


func spend_coins(amount: int) -> bool:
	if amount <= 0:
		return false
	if not can_afford(amount):
		insufficient_coins.emit(amount, current_coins)
		return false
	current_coins -= amount
	coins_changed.emit(current_coins, -amount)
	coins_spent.emit(amount, current_coins)
	return true


func reset_for_new_run() -> void:
	var previous: int = current_coins
	current_coins = 0
	coins_changed.emit(current_coins, -previous)


func debug_set_coins(value: int) -> void:
	var clamped: int = maxi(0, value)
	var delta: int = clamped - current_coins
	current_coins = clamped
	coins_changed.emit(current_coins, delta)


func debug_reset_wallet() -> void:
	reset_for_new_run()


func debug_grant_test_coins(amount: int = 100) -> bool:
	return add_coins(amount)
