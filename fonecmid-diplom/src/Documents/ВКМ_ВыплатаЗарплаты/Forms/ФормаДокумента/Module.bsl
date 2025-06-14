#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
    // СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
    // СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
    ПодключаемыеКомандыКлиент.ПослеЗаписи(ЭтотОбъект, Объект, ПараметрыЗаписи);
КонецПроцедуры
	
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Заполнить(Команда)
	
	ЗаполнитьНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьНаСервере()
	
	ДатаДокумента = Объект.Дата;
	МесяцДокумента = Месяц(ДатаДокумента);
	ГодДокумента = Год(ДатаДокумента);
	
	Запрос = Новый Запрос(
		"ВЫБРАТЬ
		|	ВКМ_ВыплатаЗарплаты.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.ВКМ_ВыплатаЗарплаты КАК ВКМ_ВыплатаЗарплаты
		|ГДЕ
		|	МЕСЯЦ(ВКМ_ВыплатаЗарплаты.Дата) = &Месяц
		|	И ГОД(ВКМ_ВыплатаЗарплаты.Дата) = &Год
		|	И ВКМ_ВыплатаЗарплаты.Проведен = ИСТИНА");
	
	Запрос.УстановитьПараметр("Месяц", МесяцДокумента);
	Запрос.УстановитьПараметр("Год", ГодДокумента);
	
	Выборка = Запрос.Выполнить().Выбрать();	
	
	Если Выборка.Количество() <> 0 Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон("Документ выплат за %1г уже существует", Формат(ДатаДокумента, "ДФ='ММММ гггг'"));
		Сообщение.Сообщить();
		
		Возврат;
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		
		ДокументВыплатаЗарплаты = Документы.ВКМ_ВыплатаЗарплаты.СоздатьДокумент();
		ДокументВыплатаЗарплаты.Дата = ДатаДокумента;
		ДокументВыплатаЗарплаты.Записать();
		ЗначениеВРеквизитФормы(ДокументВыплатаЗарплаты, "Объект");
		
	Иначе
		
		ДокументВыплатаЗарплаты = Объект.Ссылка.ПолучитьОбъект();
		ДокументВыплатаЗарплаты.Выплаты.Очистить();	
		ДокументВыплатаЗарплаты.Записать();
		
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВКМ_ВзаиморасчетыССотрудникамиОстатки.Сотрудник КАК Сотрудник,
		|	ЕСТЬNULL(ВКМ_ВзаиморасчетыССотрудникамиОстатки.СуммаОстаток, 0) КАК СуммаОстаток
		|ИЗ
		|	РегистрНакопления.ВКМ_ВзаиморасчетыССотрудниками.Остатки(&Дата, ) КАК ВКМ_ВзаиморасчетыССотрудникамиОстатки";

	Запрос.УстановитьПараметр("Дата", Объект.Дата);
	
	Выборка = Запрос.Выполнить().Выбрать();

	Если Выборка.Количество() = 0 Тогда
		
		ЭтаФорма.Прочитать();
		
		Возврат;		
		
	КонецЕсли;
	
	Пока Выборка.Следующий() Цикл
		
		НоваяВыплата = ДокументВыплатаЗарплаты.Выплаты.Добавить();
		
		НоваяВыплата.Сотрудник = Выборка.Сотрудник;
		НоваяВыплата.Сумма = Выборка.СуммаОстаток;

	КонецЦикла;

	ДокументВыплатаЗарплаты.Записать();	
	
	ЭтаФорма.Прочитать();
		
КонецПроцедуры

#Область ПодключаемыеКоманды

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
    ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
    ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
КонецПроцедуры

&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
    ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
    ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры

// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

#КонецОбласти

#КонецОбласти