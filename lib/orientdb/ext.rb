require 'date'

class Date
  def proxy_object
    java.util.Date.new year, month - 1, day - 1, 0, 0, 0
  end
end

class DateTime
  def proxy_object
    java.util.Date.new year, month - 1, day - 1, hour, min, sec
  end
end