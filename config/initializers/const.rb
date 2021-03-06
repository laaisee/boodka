module Const
  APP_NAME = 'Boodka'
  CURRENCY_CODES = Money::Currency.all.map(&:iso_code)
  CURRENCY_CODES_SET = Set.new(CURRENCY_CODES)
  RATES_TTL_IN_SECONDS = 86_400
  RECENT_HISTORY_LENGTH = 10
  TIME_FORMAT = '%H:%M'
  SHORT_DATE_FORMAT = '%e %b'
  FULL_DATE_FORMAT = '%e %b %Y'
  BUDGET_DATE_FORMAT = '%B %Y'
  DATEPICKER_FORMAT_MOMENTJS = 'D/M/YYYY HH:mm'
  DATEPICKER_FORMAT_PARSE = '%d/%m/%Y %H:%M'
  PERIODS_PER_PAGE = 2

  OUTFLOW = 0
  INFLOW = 1

  DIRECTIONS = {
    outflow: OUTFLOW,
    inflow: INFLOW
  }

  TZ = 'Moscow'
end
