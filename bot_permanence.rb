require 'json'
require 'open-uri'
require 'date'
require 'amazing_print'

URL = URI.open("https://www.la-permanence.com/services/meeting-rooms/bookings/listing?from_date=#{Date.today.day}%2F#{Date.today.month}%2F#{Date.today.year}&space_id=4").read

meeting = JSON.parse(URL)

meeting.each do |meet|
  ap "#{meet["meeting_room"]["name"]} #{DateTime.parse(meet["from"]).strftime("%H:%m")} TO #{DateTime.parse(meet["to"]).strftime("%H:%m")}"
end