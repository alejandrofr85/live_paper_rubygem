Time::DATE_FORMATS[:live_paper_date_format] = lambda { |time|
  time.strftime("%Y-%m-%dT%H:%M:%S.%3N#{time.formatted_offset(false)}")
}