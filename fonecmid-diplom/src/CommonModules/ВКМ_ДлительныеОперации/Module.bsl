
Функция ТяжелаяОперация(Параметры) Экспорт
	
	ТекДок = 1;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВКМ_РеализацияДоговор.Реализация КАК Реализация,
		|	ВКМ_РеализацияДоговор.Договор КАК Договор,
		|	ВКМ_РеализацияДоговор.Договор.Организация КАК Организация,
		|	ВКМ_РеализацияДоговор.Договор.ВидДоговора КАК ВидДоговора,
		|	ВКМ_РеализацияДоговор.Договор.ВКМ_АбонентскаяПлата КАК АбонентскаяПлата,
		|	ВКМ_РеализацияДоговор.Договор.ВКМ_СтоимостьЧасаРаботы КАК СтоимостьЧасаРаботы,
		|	ВКМ_РеализацияДоговор.Договор.Владелец КАК Владелец,
		|	ВКМ_РеализацияДоговор.Договор.ВКМ_ДатаНачалаДействияДоговора КАК ДатаНачалаДействияДоговора,
		|	ВКМ_РеализацияДоговор.Договор.ВКМ_ДатаОкончанияДействияДоговора КАК ДатаОкончанияДействияДоговора,
		|	ЗаказПокупателя.Ссылка КАК ЗаказПокупателяСсылка
		|ИЗ
		|	РегистрСведений.ВКМ_РеализацияДоговор КАК ВКМ_РеализацияДоговор
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказПокупателя КАК ЗаказПокупателя
		|		ПО ВКМ_РеализацияДоговор.Договор.Владелец = ЗаказПокупателя.Контрагент
		|			И ВКМ_РеализацияДоговор.Договор.Ссылка = ЗаказПокупателя.Договор.Ссылка
		|			И ВКМ_РеализацияДоговор.Договор.Организация = ЗаказПокупателя.Организация
		|ГДЕ
		|	ВКМ_РеализацияДоговор.Период >= &ДатаНачала
		|	И ВКМ_РеализацияДоговор.Период <= &ДатаОкончания";
	
	ДатаНачала = Параметры.Период.ДатаНачала;
	ДатаОкончания = Параметры.Период.ДатаОкончания;
	Если ДатаНачала = Дата(1, 1, 1) И ДатаОкончания = Дата(1, 1, 1) Тогда
		ДатаОкончания = Дата(3999, 12, 31);
	КонецЕсли;
	 
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", ДатаОкончания);	
	
	Выборка = Запрос.Выполнить().Выбрать();

	ВсегоДокументов = Выборка.Количество();
	
	Пока Выборка.Следующий() Цикл
		
		Если Не ЗначениеЗаполнено(Выборка.Реализация) Тогда
			
			ДокументРеализация = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
			ДокументРеализация.Дата = ТекущаяДата();
			ДокументРеализация.Договор = Выборка.Договор;
			ДокументРеализация.Организация = Выборка.Организация;
			ДокументРеализация.Контрагент = Выборка.Владелец;
			ДокументРеализация.Ответственный = Пользователи.ТекущийПользователь();
			ДокументРеализация.Основание = Выборка.ЗаказПокупателяСсылка;
			
			ВКМ_ВыполнитьАвтозаполнение(ДокументРеализация, Выборка.Договор);
			
			ДокументРеализация.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
			
		КонецЕсли;
	
		ПроцентВыполнения = (ТекДок / ВсегоДокументов) * 100;
		ПроцентВыполнения = Окр(ПроцентВыполнения, 0);
		
		ДлительныеОперации.СообщитьПрогресс(ПроцентВыполнения, СокрЛП(Выборка.Договор));
		
		ТекДок = ТекДок + 1;
				
	КонецЦикла;
	
КонецФункции

Процедура ВКМ_ВыполнитьАвтозаполнение(ДокументРеализация, Договор) Экспорт
	
	НоменклатураАбонентскаяПлата = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
	НоменклатураРаботыСпециалиста = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить();
	
	Если НоменклатураАбонентскаяПлата.Код = "" Или НоменклатураРаботыСпециалиста.Код = "" Тогда
		
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Не заполнены константы НоменклатураАбонентскаяПлата или НоменклатураРаботаСпециалиста";
		Сообщение.Сообщить();
		
		Возврат;
		
	КонецЕсли;

	ДокументРеализация.Товары.Очистить();

	СуммаДокумента = 0;
	
	Если Договор.ВКМ_АбонентскаяПлата <> 0 Тогда
		
		НовыйТовар = ДокументРеализация.Товары.Добавить();
		
		НовыйТовар.Номенклатура = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
		НовыйТовар.Количество = 1;
		НовыйТовар.Цена = Договор.ВКМ_АбонентскаяПлата;
		НовыйТовар.Сумма = Договор.ВКМ_АбонентскаяПлата;
		
		СуммаДокумента = НовыйТовар.Сумма;
		
		ДокументРеализация.Записать();
		
	КонецЕсли;

	ДокументРеализация.Услуги.Очистить();	
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	СУММА(ЕСТЬNULL(ВКМ_ВыполненныеКлиентуРаботы.КоличествоЧасов, 0)) КАК КоличествоЧасов,
		|	СУММА(ЕСТЬNULL(ВКМ_ВыполненныеКлиентуРаботы.СуммаКОплате, 0)) КАК СуммаКОплате
		|ИЗ
		|	РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы КАК ВКМ_ВыполненныеКлиентуРаботы
		|ГДЕ
		|	ВКМ_ВыполненныеКлиентуРаботы.Клиент = &Контрагент
		|	И ВКМ_ВыполненныеКлиентуРаботы.Договор = &Договор
		|	И МЕСЯЦ(ВКМ_ВыполненныеКлиентуРаботы.Период) = МЕСЯЦ(&Период)
		|	И ГОД(ВКМ_ВыполненныеКлиентуРаботы.Период) = ГОД(&Период)";
	
	Запрос.УстановитьПараметр("Договор", Договор);
	Запрос.УстановитьПараметр("Контрагент", ДокументРеализация.Контрагент);
	Запрос.УстановитьПараметр("Период", ДокументРеализация.Дата);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл

		НоваяУслуга = ДокументРеализация.Услуги.Добавить();
		
		НоваяУслуга.Номенклатура = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить();
		НоваяУслуга.Количество = Выборка.КоличествоЧасов;
		НоваяУслуга.Цена = Выборка.СуммаКОплате / Выборка.КоличествоЧасов;
		НоваяУслуга.Сумма = Выборка.СуммаКОплате;

		СуммаДокумента = СуммаДокумента + НоваяУслуга.Сумма;
				
		ДокументРеализация.Записать();
		
	КонецЦикла;
	
	МенеджерЗаписи = РегистрыСведений.ВКМ_РеализацияДоговор.СоздатьМенеджерЗаписи();
	
	МенеджерЗаписи.Период = НачалоМесяца(ДокументРеализация.Дата);
	МенеджерЗаписи.Договор = Договор;
	МенеджерЗаписи.Прочитать();
	
	Если МенеджерЗаписи.Выбран() Тогда
		
		МенеджерЗаписи.Реализация = ДокументРеализация.Ссылка;

	Иначе

		МенеджерЗаписи = РегистрыСведений.ВКМ_РеализацияДоговор.СоздатьМенеджерЗаписи();
	
		МенеджерЗаписи.Период = НачалоМесяца(ДокументРеализация.Дата);
		МенеджерЗаписи.Договор = Договор;

		МенеджерЗаписи.Реализация = ДокументРеализация.Ссылка;
		
	КонецЕсли;

	МенеджерЗаписи.Записать();	
	
КонецПроцедуры
