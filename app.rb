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
  statement = @@client.prepare(<<-SQL)
    INSERT INTO events(name, event_date, details, reminder, animals)
    VALUES (?, ?, ?, ?, ?)
  SQL
  statement.execute(
    params[:name],
    Time.parse(params["event_date"]),
    params[:details],
    Time.parse(params[:reminder]),
    params[:animals]
  )

  res = @@client.query(<<-SQL).first
    SELECT * FROM events WHERE name = '#{params[:name]}'
    ORDER BY CREATED_AT DESC
    LIMIT 1
  SQL
  res.to_json
end

get '/events/:id.json' do
  content_type :json
  res = @@client.query("SELECT * FROM events WHERE id = #{params[:id]}").first
  res.to_json
end
