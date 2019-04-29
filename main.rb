require_relative "valid"
require_relative "instance_counter"
require_relative "manufacturer"
require_relative "station"
require_relative "route"
require_relative "train"
require_relative "wagon"
require_relative "cargo_train"
require_relative "cargo_wagon"
require_relative "passenger_train"
require_relative "passenger_wagon"

class Controller

def initialize
  @stations = []
  @trains = []
  @routes = []
end

  def list_of_trains
    puts "Доступные поезда:"
    @trains.each.with_index(1) do |train, index|
      puts "#{index}: номер: '#{train.number}', тип: #{train.type}"
    end
  end

  def list_of_stations
    puts "Доступные станции:"
    @stations.each.with_index(1) do |station, index|
      puts "#{index} - #{station.title}"
    end
  end

  def list_of_routes
    puts "Доступные маршруты:"
    @routes.each.with_index(1) do |route, index|
      print "#{index} : #{route.start_station.title} - #{route.end_station.title} ПОЛНЫЙ МАРШРУТ:"
      route = route.stations
      route.each {|station| print "#{station.title} - "}
      puts ""
    end
  end

  def select_train
    puts "Выберите поезд"
    list_of_trains
    train = @trains[Integer(gets) - 1]
    train.valid?
    train
    rescue ArgumentError => e
      puts "Неверный формат ввода:#{e.message}"
      retry
    rescue RuntimeError, NoMethodError => e
      puts "Поезд не существует:#{e.message}"
      retry
  end

  def select_station
      puts 'Выберите станцию'
      list_of_stations
      station = @stations[Integer(gets) - 1]
      station.valid?
      station
    rescue ArgumentError => e
      puts "Неверный формат ввода:#{e.message}"
      retry
    rescue RuntimeError, NoMethodError => e
      puts "Станция не существует:#{e.message}"
      retry
  end

  def select_route
      puts 'Выберите маршрут'
      list_of_routes
      route = @routes[Integer(gets) - 1]
      route.valid?
      route
    rescue ArgumentError => e
      puts "Неверный формат ввода:#{e.message}"
      retry
    rescue RuntimeError, NoMethodError => e
      puts "Маршрут не существует:#{e.message}"
      retry
  end

  def select_wagon(train)
      puts 'Выберите вагон, который нужно отцепить'
      train.wagons.each {|wagon| print wagon.id.to_s + " "}
      puts ""
      wagon_number = Integer(gets)
      index_wagon = train.wagons.index { |wagon| wagon.id == wagon_number}
      wagon = train.wagons[index_wagon]
    rescue ArgumentError => e
      puts "Неверный формат ввода:#{e.message}"
      retry
    rescue TypeError => e
      puts "Вагон не существует:#{e.message}"
      retry
  end

  def add_station
    loop do
      puts "Введите название станции"
      title = gets.chomp
      @stations << Station.new(title)
      puts "Добавить еще станцию?(введите 'д' или 'н' )"
      break if gets.chomp == "н"
    end
    rescue RuntimeError => e
      puts "#{e.inspect}.Попробуйте снова!"
      retry
  end

  def add_train
    loop do
      puts "Какой тип поезда вы хотите создать?
      \rп - пассажирский, г -грузовой."
      train_type = gets.chomp
      raise ArgumentError, "Неверные данные."  if !"пг".include? train_type
      puts "Введите номер поезда:"
      number_train = gets.chomp
      if train_type == "п"
         @trains << PassengerTrain.new(number_train)
      else train_type == "г"
        @trains << CargoTrain.new(number_train)
      end
      puts "Добавить еще поезд?(введите 'д' или 'н' )"
      break if gets.chomp == "н"
    end
   rescue RuntimeError,ArgumentError => e
      puts e.message
      retry
  end

  def add_route
    puts "\nВыберите начальную станцию"
    start_station = select_station
    puts "Выберите конечную станцию"
    end_station = select_station
    @routes << Route.new(start_station, end_station)
    puts "Маршрут создан!
    \rДобавить промежуточные станции? (введите 'д' или 'н' )"
    user_answer = gets.chomp
    if user_answer == 'д'
      loop do
        puts "Выберите промежуточную станцию"
        middle_station = select_station
        @routes.last.add_station(middle_station)
        puts "Добавить еще станцию? (введите 'д' или 'н')"
        break if gets.chomp == 'н'
      end
    end
  end

  def add_wagon
    loop do
      train = select_train
      puts "Выбран поезд: #{train.number}, тип: #{train.type}"
      puts "Укажите номер вагона"
      number_wagon = Integer(gets)
      if train.is_a? PassengerTrain
        wagon = PassengerWagon.new(number_wagon)
      else
        wagon = CargoWagon.new(number_wagon)
      end
      train.add_wagon(wagon)
      puts "Добавить еще вагон? (введите 'д' или 'н')"
      break if gets.chomp == 'н'
    end
    rescue Exception => e
      puts "#{e.message} Попробуйте еще раз!"
      retry
  end

  def delete_wagon
    train = select_train
    puts "Выбран поезд: #{train.number}, тип: #{train.type}"
    wagon = select_wagon(train)
    train.delete_wagon(wagon)
  end

  def add_route_to_train
    train = select_train
    route = select_route
    train.add_route(route)
    puts "Маршрут к поезду добавлен!"
  end

  def move_train
    train = select_train
    puts "Куда перемещаем? в-вперед, н-назад"
    move = gets.chomp
    if move == "в"
      train.forward
    elsif move == "н"
      train.back
    else
      puts "Неизвестное направление"
    end
  end

  def info_station
    station = select_station
    station.trains.each {|train| puts train.number }
  end


  def main_menu
  puts "Выберите действие, которое вы хотите сделать
        1 - создать станции
        2 - создать поезд
        3 - создать маршрут
        4 - назначить маршрут поезду
        5 - добавить вагоны к поезду
        6 - отцепить вагон от поезда
        7 - переместить поезд по маршруту (вперед, назад)
        8 - посмотреть список станций и список поездов на станции
        0 - выход"
  end


  def run
    loop do
    main_menu
    act = gets.chomp.to_i
    break if act == 0
    case act
      when 1
        add_station
      when 2
        add_train
      when 3
        add_route
      when 4
        add_route_to_train
      when 5
        add_wagon
      when 6
        delete_wagon
      when 7
        move_train
      when 8
        info_station
      else
        puts "Неизвестное действие"
      end
    end
  end
end

Controller.new.run
