#import libraries
require 'sinatra'
require 'puma'
require 'http'
require 'json'
require 'date'
require 'pry'

#global variables for querying the api
$base = 'https://frc-api.firstinspires.org/v3.0'
$username = "scarlett"
$password = "65aff4eb-f687-4b6f-b793-445667d4965d"
$event_key = ''
$season = 2023 #Time.new.year
$matches = []

helpers do
  def input(type, name, placeholder)
    "<p><input type=\"#{type}\" name=\"#{name}\" placeholder=\"#{placeholder}\"></p>"
  end

  def human_date(day_num) #give the name of the day of the week given the wday number
    switch day_num
    case 0
      'Sunday'
    case 1
      'Monday'
    case 2
      'Tuesday'
    case 3
      'Wendesday'
    case 4
      'Thursday'
    case 5
      'Friday'
    case 6
      'Saturday'
    end
  end
end

get '/' do
  @title = 'Event tracker'
  erb :settings
end

post "/" do
  $event_key = params[:key]
  thread = Thread.new { get_matches }
  @title = params[:name]
  thread.join

  redirect '/schedule'
end

get '/schedule' do
  @matches = $matches
  erb :index
end

get '/update' do #update the scores as needed
  threads = []
  $matches.each do |match|
    threads << Thread.new { fetch(match[:match_num].match(/\d+/)[0].to_i) }
  end

  threads.each do |t|
    t.join
  end
  $matches.to_json
end

def color_to_number color
  if color == "Red"
    1
  else
    0
  end
end

def fetch match_num #helper method to fetch match results and return rp from a match
  request = HTTP.basic_auth(user: $username, pass: $password)
                .headers('Content-Type': 'application/json')
                .get("#{$base}/#{$season}/scores/#{$event_key}/qual?matchNumber=#{match_num}")
  alliance_data = JSON.parse(request.body)['MatchScores'][0]['alliances']
  $matches.each do |match|
    if match[:match_num].match(/\d+/)[0].to_i == match_num      
      match[:teams].each do |team|
        team[:rp] ||= alliance_data[color_to_number(team[:alliance])]['rp']
        team[:score] = alliance_data[color_to_number(team[:alliance])]['totalPoints']
      end
      break
    end
  end
  sort_matches
end
#variable["MatchScores"][0]["alliances"][color_to_number($matches[0][:teams][1])]['rp']

def get_matches #[{match_num, teams: [{team_num, alliance, rp, score}]}]
  request = HTTP.basic_auth(user: $username, pass: $password)
                .headers('Content-Type': 'application/json')
                .get("#{$base}/#{$season}/schedule/#{$event_key}?tournamentLevel=Qualification&teamNumber=461")
  JSON.parse(request.body)["Schedule"].each do |match| #the structure of the response is silly, but this will find the alliance color
    match_data = {match_num: "qm#{sprintf('%02d', match['matchNumber'])}", teams: []}
    match['teams'].each do |team|
      match_data[:teams] << {team_num: team['teamNumber'], alliance: team['station'].match(/\D+/)[0], rp: false, score: 0}
    end
    $matches << match_data
  end
  sort_matches
end

def sort_matches
  $matches.each do |match|
    match[:teams].sort!{ |a, b| a[:team_num] <=> b[:team_num] }.sort!{ |a, b| b[:alliance] <=> a[:alliance] }
  end
end
