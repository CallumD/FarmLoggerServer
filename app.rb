require 'sinatra'
require 'json'
require 'mysql2'

password = File.read('.password').chomp

@@client = Mysql2::Client.new(
  :host     => 'localhost',
  :username => 'root',
  :password => password,
  :database => 'FarmLogger'
)

get '/events.json' do
  content_type :json
  res = @@client.query("SELECT * FROM events").map { |row| row }
  res.to_json
end

post '/events.json' do
  content_type :json
  statement = @@client.prepare("insert into events(name) values (?)")
  result1 = statement.execute(params[:name])
  res.to_json
end

get '/events/:id.json' do
  content_type :json
  res = @@client.query("SELECT * FROM events where id = #{params[:id]}").first
  res.to_json
end
