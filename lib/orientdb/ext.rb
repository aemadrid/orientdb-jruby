require 'date'

class Date
  def proxy_object
    java.util.Date.new year, month - 1, day, 0, 0, 0
  end
end

class DateTime
  def proxy_object
    java.util.Date.new year, month - 1, day, hour, min, sec
  end
end