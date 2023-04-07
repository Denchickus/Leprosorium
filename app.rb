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
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts 
	(
    	id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
    	created_date BLOB (256),
    	content TEXT
	);'
end

get '/' do
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

	erb "You typed #{content}"
end