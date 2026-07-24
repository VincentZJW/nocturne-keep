class_name CoinPickup
extends WorldPickup

@export_range(1, 999, 1) var coin_amount: int = 1


func set_pickup_amount(amount: int) -> void:
	coin_amount = maxi(1, amount)


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null or player.is_dead() or _consumed:
		return
	var wallet: CurrencyWallet = get_node_or_null("/root/CurrencyManager") as CurrencyWallet
	if wallet != null and wallet.add_coins(coin_amount):
		_consume()
