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

@stations = []
@trains = []
@routes = []

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
  rescue RuntimeError => e
    puts "Поезд не существует:#{e.message}"
    retry
  rescue NoMethodError => e
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
  rescue RuntimeError => e
    puts "Станция не существует:#{e.message}"
    retry
  rescue NoMethodError => e
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
  rescue RuntimeError => e
    puts "Маршрут не существует:#{e.message}"
    retry
  rescue NoMethodError => e
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

loop do
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

act = gets.chomp.to_i

break if act == 0

case act

  when 1
    begin
      loop do
       puts "\nКоличество станций: #{Station.instances}"
       puts "Введите название станции
       \r(введите 'стоп' для прекращения ввода)"
       title = gets.chomp
       break if title == "стоп"
       @stations << Station.new(title)
       end
    rescue RuntimeError => e
      puts e.inspect
      retry
    end

  when 2
    begin
      loop do
        puts "Какой тип поезда вы хотите создать?
        \rп - пассажирский, г -грузовой."
        train_type = gets.chomp
        puts "Введите номер поезда:"
        number_train = gets.chomp
        if train_type == "п"
           @trains << PassengerTrain.new(number_train)
        elsif train_type == "г"
          @trains << CargoTrain.new(number_train)
        else
          puts "Такой тип поезда создать невозможно!"
        end
        puts "Количество поездов типа #{@trains.last.type}:  #{@trains.last.class.instances}"
        puts "Добавить еще поезд? (введите 'д' или 'н' )"
        user_answer = gets.chomp
        break if user_answer == "н"
      end
    rescue RuntimeError => e
      puts e.inspect
      retry
    end

  when 3
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
        user_answer = gets.chomp
        break if user_answer == 'н'
      end
    end

  when 4
    train = select_train
    route = select_route
    train.add_route(route)
    puts "Маршрут к поезду добавлен!"

  when 5
    train = select_train
    puts "Выбран поезд: #{train.number}, тип: #{train.type}"
    begin
      loop do
        puts "Укажите номер вагона"
        number_wagon = Integer(gets)
        if train.is_a? PassengerTrain
          wagon = PassengerWagon.new(number_wagon)
        else
          wagon = CargoWagon.new(number_wagon)
        end
        train.add_wagon(wagon)
        puts "Добавить еще вагон? (введите 'д' или 'н')"
        user_answer = gets.chomp
        break if user_answer == 'н'
      end
      rescue Exception => e
        puts "#{e.message} Попробуйте еще раз!"
        retry
      end

  when 6
    train = select_train
    puts "Выбран поезд: #{train.number}, тип: #{train.type}"
    wagon = select_wagon(train)
    train.delete_wagon(wagon)

  when 7
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

  when 8
    station = select_station
    station.trains.each {|train| puts train.number }

  else
    puts "Неизвестное действие"
  end
end


