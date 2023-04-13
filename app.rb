#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true #эта настройка нужна, чтобы результаты возвращались в виде хэша, а не массива

end
#before вызывается каждый раз при перезагрузке любой страницы
before do #before выполняется каждый раз перед выполнением любого HTTP-запроса, не исполняется при конфигурации configure
	init_db #поэтому в configure надо написать тоже init_db
end

configure do #configure вызывается каждый раз когда мы изменяем код, сохраняем его и перезапускаем прложение
	#инициализация БД
	init_db
	# создаёт таблицу, если она не существует
	# следующий код - миграция, нужен для синхронизации кода приложения со структурой БД
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts 
	(
    	id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
    	created_date BLOB (256),
    	content TEXT
	);'
end

get '/' do
	#выбираем список постов из БД

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index 			
end

get '/new' do
	erb :new
end

post '/new' do
	content = params[:content]

	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	#Сохранение данных в БД

	@db.execute 'insert into Posts (content, created_date) values (?, datetime());', [content]


	#перенаправление на главную страницу

	redirect to('/')
end

#вывод информации о посте
# на место :post_id подставляется номер поста
# получаем параметр из адресной строки
get '/details/:post_id' do
	# получаем переменную из url 
	post_id = params[:post_id]
	# получаем список постов
	# (у нас будет только один пост)
	results = @db.execute 'select * from Posts where id=?', [post_id]
	# выбираем этот один пост в переменную @row
	@row = results[0]
	# возвращаем представление details.erb
	erb :details
end