extends Node

var os = OS.get_name()
var firebase = null
var viewEventOptiopnalDebug = true
# RECOMMENDED FIREBASE EVENTS
enum FirebaseEvent {
	add_payment_info = 0, add_shipping_info, add_to_cart, add_to_wishlist, ad_impression, app_open, begin_checkout, campaign_details, earn_virtual_currency,
	generate_lead, join_group, level_end, level_start, level_up, login, post_score, purchase, refund, remove_from_cart, screen_view, search,
	select_content, select_item, select_promotion, share, sign_up, spend_virtual_currency, tutorial_begin, tutorial_complete, unlock_achievement, 
	view_cart, view_item, view_item_list, view_promotion, view_search_results
}
# NOT USE FOR EVENT NAME
enum FirebaseEventNotUse {
	ad_activeview = 0, ad_click, ad_exposure, ad_impression, ad_query, ad_reward, adunit_exposure, app_background, app_clear_data, 
	app_exception, app_exception, app_store_refund, app_store_subscription_cancel, app_store_subscription_convert, 
	app_store_subscription_renew, app_update, app_upgrade, dynamic_link_app_open, dynamic_link_app_update, dynamic_link_first_open, 
	error, first_open, first_visit, in_app_purchase, notification_dismiss, notification_foreground, notification_open, notification_receive, 
	os_update, session_start, session_start_with_rollout, user_engagement
}
# PARAMS NAME FOR RECOMMENDED FIREBASE EVENTS
enum FirebaseParams {
	achievement_id = 0, aclid, ad_format, ad_platform, ad_source, ad_unit_name, affiliation, campaign, character, content, content_type, 
	coupon, cp1, creative_name, creative_slot, currency, destination, discount, end_date, extend_session, flight_number,
	group_id, index, items, item_brand, item_category, item_category2, item_category3, item_category4, item_category5, item_id, item_list_id, 
	item_list_name, item_name, item_variant, level, level_name, location, location_id, medium, method, number_of_nights, number_of_passengers,
	number_of_rooms, origin, payment_type, price, promotion_id, promotion_name, quantity, score, screen_class, screen_name, search_term,
	shipping, shipping_tier, source, start_date, success, tax, term, transaction_id, travel_class, value, virtual_currency_name
}

# В плагин планировалось добавить аутентификацию, она не добавлена и добавление отменено. В любом случае аналитика была протестирована и работает
## Представляет информацию профиля пользователя в базе данных пользователей вашего проекта Firebase. 
## Он также содержит вспомогательные методы для изменения или извлечения информации профиля, 
## а также для управления состоянием аутентификации этого пользователя.
#class FirebaseUser:
#	var isNull = null
#	func printData():
#		print("FirebaseUser: isNull: %s"%[isNull])
#	func make(data:Dictionary):
#		isNull = data.isNull

signal returnAppInstanceId(appId)
signal getInstance
signal getSessionId(sessionId)



#var firebaseUser:FirebaseUser = FirebaseUser.new()
#enum signInButtonType { FirebaseUI = 0 }

signal getCurrentUserSignal

func on_getInstanceSignal():
	print("on_getInstanceSignal")
	emit_signal("getInstance")
	pass

func on_getAppInstanceIdSignal(appId:String):
	emit_signal("returnAppInstanceId", appId)

func on_getSessionIdSignal(sessionId:int):
#	sessionId -1 = null
	emit_signal("getSessionId", sessionId)

func _ready():
	print("os %s"%[os])
	match os:
		"Android":
			if Engine.has_singleton("AFirebase"): 
				firebase = Engine.get_singleton("AFirebase")
				firebase.getInstance();
				firebase.connect("getInstanceSignal", self, "on_getInstanceSignal")
				firebase.connect("getAppInstanceIdSignal", self, "on_getAppInstanceIdSignal")
				firebase.connect("getSessionIdSignal", self, "on_getSessionIdSignal")
				print("AFirebase good")
			else:
				print("AFirebase !has")

# Извлекает идентификатор экземпляра приложения из службы или null,
# если FirebaseAnalytics.ConsentType.ANALYTICS_STORAGE был установлен
# в FirebaseAnalytics.ConsentStatus.DENIED.
func getAppInstanceId():
	print("getAppInstanceId")
	firebase.getAppInstanceId()

func getSessionId():
	firebase.getSessionId()


# example
# logEvent("testEvent", {testParam1": {"value": "stringParam", "type": "string"}, "testParam2": {...}, ... })
# event: int(enum FirebaseEvent)/String
# params: Dictionary
func logEvent(event, params: Dictionary): 
#	ЗАПИСЬ EVENT И EVENTID
#   eventID если event !custom
	var eventID 
	if typeof(event) == TYPE_INT: 
		eventID = event
		event = FirebaseEvent.keys()[event]
		print("logEvent, !Custom event %s, eventID %s"%[event, eventID])
	elif typeof(event) == TYPE_STRING:
		if FirebaseEvent.keys().find(event):
			eventID = FirebaseEvent.keys()[event]
			print("logEvent, !Custom event %s, eventID %s"%[event, eventID])
		else:
			print("logEvent, Custom event %s"%[event])
	else:
		print("logEvent, name/event error(%s), type != string or int"%[event])
		return
		
#	ПРОВЕРКА EVENT NAME
	if FirebaseEventNotUse.keys().find(event) != -1:
		print("logEvent, name/event error(%s), name in FirebaseEventNotUse"%[event])
		return
	
#	PARAMS КЛЮЧИ ИЗ INT В STRING
	var paramsKeys = params.keys()
	var paramsValues = params.values()
	var paramsKeysStr = []
	for paramKey in paramsKeys:
		if typeof(paramKey) == TYPE_INT:
			paramsKeysStr.append(FirebaseParams.keys()[paramKey])
		elif typeof(paramKey) == TYPE_STRING:
			paramsKeysStr.append(paramKey)
	params.clear()
	for i in paramsKeysStr.size(): 
		params[paramsKeysStr[i]] = paramsValues[i]
	
#	ОТПРАВИТЬ LOGEVENT
	firebase.logEvent(event, params)

# ОБЁРТКИ РЕКОМЕНДОВАННЫХ СОБЫТИЙ
func logEvent_LevelStart(levelName: String): 
	logEvent(FirebaseEvent.level_start, {
		FirebaseParams.keys()[FirebaseParams.level_name]: { "value": levelName, "type": "string" }
	});
func logEvent_LevelEnd(levelName: String, success: bool): 
	logEvent(FirebaseEvent.level_end, {
		FirebaseParams.keys()[FirebaseParams.level_name]: { "value": levelName, "type": "string"},
		FirebaseParams.keys()[FirebaseParams.success]: { "value": int(success), "type": "long"}
	})
func logEvent_LevelUp(level: int, character: String):
	logEvent(FirebaseEvent.level_up, {
		FirebaseParams.keys()[FirebaseParams.character]: {"value": character, "type": "string"},
		FirebaseParams.keys()[FirebaseParams.level]: {"value": level, "type": "long"},
	})
func logEvent_EarnVirtualCurrency(virtualCurrencyName: String, value: float):
	logEvent(FirebaseEvent.earn_virtual_currency, {
		FirebaseParams.keys()[FirebaseParams.virtual_currency_name]: {"value": virtualCurrencyName, "type": "string"},
		FirebaseParams.keys()[FirebaseParams.value]: {"value": value, "type": "double"},
	})
func logEvent_SpendVirtualCurrency(item_name: String, virtualCurrencyName: String, value: float):
	logEvent(FirebaseEvent.spend_virtual_currency, {
		FirebaseParams.keys()[FirebaseParams.item_name]: {"value": item_name, "type": "string"},
		FirebaseParams.keys()[FirebaseParams.virtual_currency_name]: {"value": virtualCurrencyName, "type": "string"},
		FirebaseParams.keys()[FirebaseParams.value]: {"value": value, "type": "double"},
	})
func logEvent_TutorialBegin():
	logEvent(FirebaseEvent.tutorial_begin, {})
func logEvent_TutorialComplete():
	logEvent(FirebaseEvent.tutorial_complete, {})
func logEvent_UnlockAchievement(achievement_id: String):
	logEvent(FirebaseEvent.unlock_achievement, {
		FirebaseParams.keys()[FirebaseParams.achievement_id]: {"value": achievement_id, "type": "string"}
	})
func logEvent_ScreenView(screen_name: String, screen_class: String):
	logEvent(FirebaseEvent.screen_view, {
		FirebaseParams.keys()[FirebaseParams.screen_name]: {"value": screen_name, "type": "string"},
		FirebaseParams.keys()[FirebaseParams.screen_class]: {"value": screen_class, "type": "string"}
	})

# Удаляет с устройства все аналитические данные для этого приложения и сбрасывает идентификатор экземпляра приложения.
func resetAnalyticsData():
	firebase.resetAnalyticsData()

# Определяет, включен ли сбор аналитики для этого приложения на данном устройстве. 
# Этот параметр сохраняется во всех сеансах приложения. По умолчанию он включен.
func setAnalyticsCollectionEnabled(enabled: bool):
	firebase.setAnalyticsCollectionEnabled(enabled)

# Устанавливает применимое состояние согласия конечного пользователя
# (например, для идентификаторов устройств) для этого приложения на данном устройстве.
# Используйте карту согласия, чтобы указать индивидуальные значения типа согласия.
# Настройки сохраняются во всех сеансах приложения. По умолчанию для типов согласия установлено значение "предоставлено".
func setConsent(analytics_storage: bool, adStorage: bool):
	firebase.setConsent(analytics_storage, adStorage)

# Добавляет параметры, которые будут устанавливаться для каждого события, регистрируемого из SDK, 
# включая автоматические. Значения, переданные в пакете параметров, будут добавлены к карте 
# параметров события по умолчанию. Эти параметры сохраняются при запуске приложения. 
# Они имеют более низкий приоритет, чем параметры события, поэтому, если параметр события и параметр, 
# установленный с помощью этого API, имеют одинаковое имя, будет использоваться значение параметра события. 
# Те же ограничения на параметры события применяются и к параметрам события по умолчанию.
# Пример
# setDefaultEventParameters({ {"paramName1":"name", "type":"string"}, {"param2":"name", "type":"long"} })
func setDefaultEventParameters(parameters:Dictionary):
	firebase.setDefaultEventParameters(parameters)

# Задает продолжительность бездействия, которая завершает текущий сеанс. 
# Значение по умолчанию равно 1800000 (30 минут).
func setSessionTimeoutDuration(milliseconds: int):
	firebase.setSessionTimeoutDuration(milliseconds)

# Задает свойство user ID. Эта функция должна использоваться в соответствии с Политикой конфиденциальности Google.
func setUserId(id: String):
	if id.length() > 256: 
		print("Remote.setUserId, id.length > 256")
	else:
		firebase.setUserId(id)
#		if firebase.setUserId(id) == 0: print("Remote.setUserId, id.length > 256")

# Устанавливает пользовательскому свойству заданное значение. 
# Поддерживается до 25 имен пользовательских свойств. 
# После установки значения пользовательских свойств сохраняются на протяжении всего жизненного цикла приложения и в разных сеансах.
func setUserProperty(name:String, value:String):
	firebase.setUserProperty(name, value)


