
#Область ОбработчикиСобытийЭлементовТаблицыФормы

&НаКлиенте
Процедура ОтпускаСотрудниковДатаНачалаПриИзменении(Элемент)

	ДатаНачалаОтпуска = ТекущийЭлемент.ТекущиеДанные.ДатаНачала;
	
	Если Год(ДатаНачалаОтпуска) <> Объект.Год Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Неправильный год отпуска.";
		Сообщение.Сообщить();
		
		Возврат;
		
	КонецЕсли;
	
	ДатаОкончанияОтпуска = ТекущийЭлемент.ТекущиеДанные.ДатаОкончания;
	
	Если Не ЗначениеЗаполнено(ДатаОкончанияОтпуска) Тогда
		
		Объект.ПометкаУдаления = Ложь;
		Возврат;
		
	Иначе
		
		Если ДатаНачалаОтпуска >= ДатаОкончанияОтпуска Тогда

			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Дата начала отпуска должна быть меньше даты окончания отпуска.";
			Сообщение.Сообщить();
		
			Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Сотрудник = ТекущийЭлемент.ТекущиеДанные.Сотрудник;
	
	КоличествоДнейОтпуска = ПроверитьКоличествоДнейОтпуска(Сотрудник);
	
	ПрОтпуска = (КоличествоДнейОтпуска > 28);
		
	УстановкаПризнакаОтпусков(Сотрудник, ПрОтпуска);

	ЭтаФорма.Прочитать();	
	
КонецПроцедуры

&НаКлиенте
Процедура ОтпускаСотрудниковДатаОкончанияПриИзменении(Элемент)

	ДатаОкончанияОтпуска = ТекущийЭлемент.ТекущиеДанные.ДатаОкончания;
	
	Если Год(ДатаОкончанияОтпуска) <> Объект.Год Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Неправильный год отпуска.";
		Сообщение.Сообщить();
		
		Возврат;
		
	КонецЕсли;
	
	ДатаНачалаОтпуска = ТекущийЭлемент.ТекущиеДанные.ДатаНачала;
	
	Если Не ЗначениеЗаполнено(ДатаНачалаОтпуска) Тогда
		
		Объект.ПометкаУдаления = Ложь;
		Возврат;
		
	Иначе
		
		Если ДатаОкончанияОтпуска <= ДатаНачалаОтпуска Тогда

			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Дата начала отпуска должна быть меньше даты окончания отпуска.";
			Сообщение.Сообщить();
		
			Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Сотрудник = ТекущийЭлемент.ТекущиеДанные.Сотрудник;
	
	КоличествоДнейОтпуска = ПроверитьКоличествоДнейОтпуска(Сотрудник);

	ПрОтпуска = (КоличествоДнейОтпуска > 28);
		
	УстановкаПризнакаОтпусков(Сотрудник, ПрОтпуска);
	
	ЭтаФорма.Прочитать();
	
КонецПроцедуры

#КонецОбласти 

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПроверитьКоличествоДнейОтпуска(Сотрудник)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_ГрафикОтпусковОтпускаСотрудников.ДатаНачала КАК ДатаНачала,
		|	ВКМ_ГрафикОтпусковОтпускаСотрудников.ДатаОкончания КАК ДатаОкончания
		|ИЗ
		|	Документ.ВКМ_ГрафикОтпусков.ОтпускаСотрудников КАК ВКМ_ГрафикОтпусковОтпускаСотрудников
		|ГДЕ
		|	ВКМ_ГрафикОтпусковОтпускаСотрудников.Ссылка = &Ссылка
		|	И ВКМ_ГрафикОтпусковОтпускаСотрудников.Сотрудник = &Сотрудник";
	
	Запрос.УстановитьПараметр("Сотрудник", Сотрудник);
	Запрос.УстановитьПараметр("Ссылка", Объект.Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	КоличествоДнейОтпуска = 0;
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл

		 КоличествоДнейОтпуска = КоличествоДнейОтпуска + 
		 		(НачалоДня(ВыборкаДетальныеЗаписи.ДатаОкончания) - НачалоДня(ВыборкаДетальныеЗаписи.ДатаНачала)) / (60 * 60 * 24) + 1;
		
	КонецЦикла;
	
	Возврат КоличествоДнейОтпуска;
	
КонецФункции

&НаСервере
Процедура УстановкаПризнакаОтпусков(Сотрудник, ПрОтпуска)

	Для Каждого Строка Из Объект.ОтпускаСотрудников Цикл
		
		Если Строка.Сотрудник <> Сотрудник Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Строка.ПризнакОтпуска = ПрОтпуска;
		
	КонецЦикла;
	
	ЭтотОбъект.Записать();
	
КонецПроцедуры

&НаКлиенте
Процедура АнализДокумента(Команда)
	
	СсылкаХранилища = ПолучитьСсылкаХранилища();
	
	НовыйПараметры = Новый Структура;
	НовыйПараметры.Вставить("СсылкаХранилища", СсылкаХранилища);
	
	ОткрытьФорму("Документ.ВКМ_ГрафикОтпусков.Форма.АнализДокумента", НовыйПараметры, ЭтаФорма.УникальныйИдентификатор);
	
КонецПроцедуры

&НаСервере
Функция ПолучитьСсылкаХранилища()

	ТаблицаОтпускаСотрудников = Объект.ОтпускаСотрудников.Выгрузить();
	
	СсылкаХранилища = ПоместитьВоВременноеХранилище(ТаблицаОтпускаСотрудников);
	
	Возврат СсылкаХранилища;
	
КонецФункции

#КонецОбласти 

