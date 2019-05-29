# frozen_string_literal: true

RSpec.describe FCB::UploadZippedData do
  describe '#call' do
    test_required_args = {
      # default
      funding_type: 2, # 2 – Займ
      credit_purpose_2: '09', # 09 - Прочие
      credit_object: '10', # 10 - Прочие
      real_payment_date: nil, # При фазах 5 - Погашен, 6 - Погашен досрочно, 8 - Смена  кредитора заполнение данного поля обязательно.  По действующим контрактам поле не заполняется. Дата фактического погашения не может быть больше текущей даты.
      classification: 1, # 1 - Стандартный
      collateral: 1, # 1 – Бланковые, Указывается для беззалоговых займов
      collateral_value: 0, # Если займ беззалоговый, в стоимости обеспечения необходимо передавать значение "0"
      collateral_currency: 'KZT', # Код валюты
      collateral_type: 3, # 3 – Внутренняя оценка
      instalment_payment_method_id: 6, # 6 – Другие
      instalment_payment_period_id: 9, # 9 – В день истечения срока кредитного договора
      subject_role_id: 1, # 1 – Заемщик
      accounting_date: Date.today.strftime, # Дата формирования отчета

      # Loan
      operation_type: 2, # При первоначальной загрузке контракта указывать ID значение 1, при обновлении – 2
      contract_number: 1007, # Номер договора
      contract_phase: 4, # 4,5,6,7,
      contract_status: 1, # 1,10,11,12,13,15,16
      start_date: '2013-09-10', # Дата выдачи
      end_date: '2018-09-10', # Дата конца договора
      real_payment_date: '2018-10-01',
      total_amount: 12_000, # Сумма договора
      instalment_amount: 12_000, # Сумма периодического платежа
      instalment_count: 1, # Общее количество взносов
      outstanding_instalment_count: 1, # Количество предстоящих платежей согласно графику
      outstanding_amount: 12_000, # Сумма предстоящих платежей (Непогашенная сумма)
      overdue_instalment_count: 0, # Количество дней просрочки
      overdue_amount: 0, # Сумма просроченных платежей (взносов)
      # subject
      first_name: 'Тест',
      surname: 'Тестов',
      fathers_name: 'Тестович',
      gender: 'M', # М – мужской; F – женский
      subject_classification: '1', # 1 – Физическое лицо
      residency: '1', # 1 – Резидент
      date_of_birth: '1984-01-01',
      citizenship: 110, # 110 - Гражданство KZ. Заполняется в соответствии со справочником кодов стран
      # Documents
      subject_iin: '921111300870', # Identification(:typeId => 14) - ИИН (физ. лицо)
      subject_iin_system_registration_date: '1900-01-01', # Дата регистрации ИИН в системе
      # 7 –  Удостоверение личности (физ. лицо)
      subject_identity_document_number: '040048820',
      subject_identity_document_issued_on: '2009-03-04',
      subject_identity_document_expire_on: '2029-01-09',
      subject_identity_document_system_registration_date: '1900-01-01', # Дата регистрации документа в системе
      # Adresses
      # 1 – Постоянное место жительства (физ.лицо)
      residential_address_locality: '750000000', # КАТО города жительства
      residential_address_full: 'Арычная д 29 кв 22', # Полный адрес без города
      # 6 - Место прописки (физ.лицо)
      registration_address_locality: '750000000', # КАТО города регистрации
      registration_address_full: 'Арычная д 29 кв 22', # Полный адрес без города
      # Phone
      communication_type: 3, # 3 – Мобильный
      communication: '77079335303' # Сотовый телефон
    }

    it 'returns failure if not all args pass' do
      request = FCB::UploadZippedData.new(env: :test, user_name: ENV['FCB_TEST_USERNAME'], password: ENV['FCB_TEST_PASSWORD'])
      result = request.call(args: {})
      expect(result).to be_a(Dry::Monads::Result::Failure)
      expect(result.value).to eq(missed_fields: [:funding_type, :credit_purpose_2, :credit_object, :real_payment_date, :classification, :collateral, :collateral_value, :collateral_currency, :collateral_type, :instalment_payment_method_id, :instalment_payment_period_id, :subject_role_id, :accounting_date, :operation_type, :contract_number, :contract_phase, :contract_status, :start_date, :end_date, :total_amount, :instalment_amount, :instalment_count, :outstanding_instalment_count, :outstanding_amount, :overdue_instalment_count, :overdue_amount, :first_name, :surname, :fathers_name, :gender, :subject_classification, :residency, :date_of_birth, :citizenship, :subject_iin, :subject_iin_system_registration_date, :subject_identity_document_number, :subject_identity_document_issued_on, :subject_identity_document_expire_on, :subject_identity_document_system_registration_date, :residential_address_locality, :residential_address_full, :registration_address_locality, :registration_address_full, :communication_type, :communication])
    end

    it 'returns succesfully received message' do
      request = FCB::UploadZippedData.new(env: :test, user_name: ENV['FCB_TEST_USERNAME'], password: ENV['FCB_TEST_PASSWORD'])
      result = request.call(args: test_required_args)
      puts result.value['CigResult']['Result']['Batch']
      expect(result).to be_a(Dry::Monads::Result::Success)
      expect(result.value['CigResult']['Result']['Batch']['@StatusId']).to eq('519')
    end
  end
end
