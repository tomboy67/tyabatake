class Event
  include Rhom::PropertyBag

  # 繰り返しの頻度
  RECURRENCE_FREQUENCIES = {
    nil                                         => "なし",
    Rho::RhoEvent::RECURRENCE_FREQUENCY_DAILY   => "毎日",
    Rho::RhoEvent::RECURRENCE_FREQUENCY_WEEKLY  => "毎週",
    Rho::RhoEvent::RECURRENCE_FREQUENCY_MONTHLY => "毎月",
    Rho::RhoEvent::RECURRENCE_FREQUENCY_YEARLY  => "毎年"
  }
end
