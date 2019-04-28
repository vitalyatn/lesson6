class Route
  include InstanceCounter
  attr_reader :start_station, :end_station

  def initialize(start_station, end_station)
    @start_station = start_station
    @end_station = end_station
    @railway_stations = []
    validate!
    register_instance
  end

  def add_station(station)
    raise "Станцию добавить невозможно" if station.nil?
    validate!
    @railway_stations << station
  end

  def delete_station(station)
    puts "Промежуточная станция #{station.title} удалена"
    @railway_stations.delete_if {|station_del| station_del == station }
  end

  def stations
    [@start_station, @railway_stations, @end_station].flatten
  end

  def valid?
    validate!
    true
  rescue
    false
  end

  private

   def validate!
    raise "Заданы несуществующие станции.Повторите ввод" if (start_station.nil? || end_station.nil?)
  end
end
