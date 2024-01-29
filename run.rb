begin
    require 'sinatra'
rescue
    'bundler install'
end

t = Thread.new{ 'ruby app.rb' }

sleep 5

'start microsoft-edge:http://1127.0.0.1.4567/'
t.join

