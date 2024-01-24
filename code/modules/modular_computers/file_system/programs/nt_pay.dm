#define NT_PAY_STATUS_NO_ACCOUNT 0
#define NT_PAY_STATUS_DEPT_ACCOUNT 1
#define NT_PAY_STATUS_INVALID_TOKEN 2
#define NT_PAY_SATUS_SENDER_IS_RECEIVER 3
#define NT_PAY_STATUS_INVALID_MONEY 4
#define NT_PAY_STATUS_SUCCESS 5

/datum/computer_file/program/nt_pay
	filename = "ntpay"
	filedesc = "Nanotrasen Pay System"
	downloader_category = PROGRAM_CATEGORY_DEVICE
	program_open_overlay = "generic"
	extended_desc = "An application that locally (in your sector) helps to transfer money or track your expenses and profits."
	size = 2
	tgui_id = "NtosPay"
	program_icon = "money-bill-wave"
	can_run_on_flags = PROGRAM_ALL
	circuit_comp_type = /obj/item/circuit_component/mod_program/nt_pay
	///Reference to the currently logged in user.
	var/datum/bank_account/current_user
	///Pay token what we want to find
	var/wanted_token

/datum/computer_file/program/nt_pay/ui_act(action, list/params, datum/tgui/ui, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("Transaction")
			var/token = params["token"]
			var/money_to_send = params["amount"]
			make_payment(token, money_to_send, usr)

		if("GetPayToken")
			wanted_token = null
			for(var/account in SSeconomy.bank_accounts_by_id)
				var/datum/bank_account/acc = SSeconomy.bank_accounts_by_id[account]
				if(acc.account_holder == params["wanted_name"])
					wanted_token = "Token: [acc.pay_token]"
					break
			if(!wanted_token)
				return wanted_token = "Account \"[params["wanted_name"]]\" not found."

/datum/computer_file/program/nt_pay/ui_data(mob/user)
	var/list/data = list()

	current_user = computer.computer_id_slot?.registered_account || null
	if(!current_user)
		data["name"] = null
	else
		data["name"] = current_user.account_holder
		data["owner_token"] = current_user.pay_token
		data["money"] = current_user.account_balance
		data["wanted_token"] = wanted_token
		data["transaction_list"] = current_user.transaction_history

	return data

///Wrapper and signal for the main payment function of this program
/datum/computer_file/program/nt_pay/proc/make_payment(token, money_to_send, mob/user)
	var/payment_result = _pay(token, money_to_send, user)
	SEND_SIGNAL(computer, COMSIG_MODULAR_COMPUTER_NT_PAY_RESULT, payment_result)

/datum/computer_file/program/nt_pay/proc/_pay(token, money_to_send, mob/user)
	if(IS_DEPARTMENTAL_ACCOUNT(current_user))
		if(user)
			to_chat(user, span_notice("The app is unable to withdraw from that card."))
		return NT_PAY_STATUS_DEPT_ACCOUNT

	var/datum/bank_account/recipient
	if(!token)
		if(user)
			to_chat(user, span_notice("You need to enter your transfer target's pay token."))
		return NT_PAY_STATUS_INVALID_TOKEN
	if(money_to_send <= 0)
		if(user)
			to_chat(user, span_notice("You need to specify how much you're sending."))
		return NT_PAY_STATUS_INVALID_MONEY
	if(token == current_user.pay_token)
		if(user)
			to_chat(user, span_notice("You can't send credits to yourself."))
		return NT_PAY_SATUS_SENDER_IS_RECEIVER

	for(var/account as anything in SSeconomy.bank_accounts_by_id)
		var/datum/bank_account/acc = SSeconomy.bank_accounts_by_id[account]
		if(acc.pay_token == token)
			recipient = acc
			break

	if(!recipient)
		if(user)
			to_chat(user, span_notice("The app can't find who you're trying to pay. Did you enter the pay token right?"))
		return NT_PAY_STATUS_INVALID_TOKEN
	if(!current_user.has_money(money_to_send) || money_to_send < 1)
		current_user.bank_card_talk("You cannot afford it.")
		return NT_PAY_STATUS_INVALID_MONEY

	recipient.bank_card_talk("You received [money_to_send] credit(s). Reason: transfer from [current_user.account_holder]")
	recipient.transfer_money(current_user, money_to_send)
	current_user.bank_card_talk("You send [money_to_send] credit(s) to [recipient.account_holder]. Now you have [current_user.account_balance] credit(s)")

	return NT_PAY_STATUS_SUCCESS


/obj/item/circuit_component/mod_program/nt_pay
	associated_program = /datum/computer_file/program/nt_pay
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	///Circuit variables. This one is for the token we want to pay
	var/datum/port/input/token_port
	///The port for the money to send
	var/datum/port/input/money_port
	///Let's us know if the payment has gone through or not.
	var/datum/port/output/payment_status

/obj/item/circuit_component/mod_program/nt_pay/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(associated_program.computer, COMSIG_MODULAR_COMPUTER_NT_PAY_RESULT, PROC_REF(on_payment_result))

/obj/item/circuit_component/mod_program/nt_pay/unregister_shell()
	UnregisterSignal(associated_program.computer, COMSIG_MODULAR_COMPUTER_NT_PAY_RESULT)
	return ..()

/obj/item/circuit_component/mod_program/nt_pay/populate_ports()
	. = ..()
	token_port = add_input_port("Token", PORT_TYPE_STRING)
	money_port = add_input_port("Amount", PORT_TYPE_NUMBER)
	payment_status = add_output_port("Status", PORT_TYPE_NUMBER)

/obj/item/circuit_component/mod_program/nt_pay/get_ui_notices()
	. = ..()
	. += create_ui_notice("NT-Pay Statuses:")
	. += create_ui_notice("Fail (No Account) - [NT_PAY_STATUS_NO_ACCOUNT]", "red")
	. += create_ui_notice("Fail (Dept Account) - [NT_PAY_STATUS_DEPT_ACCOUNT]", "red")
	. += create_ui_notice("Fail (Invalid Token) - [NT_PAY_STATUS_INVALID_TOKEN]", "red")
	. += create_ui_notice("Fail (Sender = Receiver) - [NT_PAY_SATUS_SENDER_IS_RECEIVER]", "red")
	. += create_ui_notice("Fail (Invalid Amount) - [NT_PAY_STATUS_INVALID_MONEY]", "red")
	. += create_ui_notice("Success - [NT_PAY_STATUS_SUCCESS]", "green")

/obj/item/circuit_component/mod_program/nt_pay/input_received(datum/port/port)
	var/datum/computer_file/program/nt_pay/program = associated_program
	program.make_payment(token_port.value, money_port.value)

/obj/item/circuit_component/mod_program/nt_pay/proc/on_payment_result(datum/source, payment_result)
	SIGNAL_HANDLER
	payment_status.set_output(payment_result)

#undef NT_PAY_STATUS_NO_ACCOUNT
#undef NT_PAY_STATUS_DEPT_ACCOUNT
#undef NT_PAY_STATUS_INVALID_TOKEN
#undef NT_PAY_SATUS_SENDER_IS_RECEIVER
#undef NT_PAY_STATUS_INVALID_MONEY
#undef NT_PAY_STATUS_SUCCESS
