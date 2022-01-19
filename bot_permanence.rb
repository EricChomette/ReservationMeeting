require 'json'
require 'open-uri'
require 'date'
require 'amazing_print'
require 'net/https'
require 'csv'

csv_file   = File.join(__dir__, 'file.csv')
old_horaires = []
new_horaires = []
URL = URI.open("https://www.la-permanence.com/services/meeting-rooms/bookings/listing?from_date=#{Date.today.day}%2F#{Date.today.month}%2F#{Date.today.year}&space_id=4").read

meeting = JSON.parse(URL)

CSV.foreach(csv_file) do |row|
  old_horaires << [row[0], row[1]]
end

meeting.each do |meet|
  # ap "#{meet["meeting_room"]["name"]} #{DateTime.parse(meet["from"]).strftime("%H:%m")} TO #{DateTime.parse(meet["to"]).strftime("%H:%m")}"
  new_horaires.append([meet["from"], meet["to"]]) if meet['meeting_room']['seats'] == 8
  # next unless DateTime.now > DateTime.parse(meet['from']) && DateTime.now < DateTime.parse(meet['to']) && meet['meeting_room']['seats'] == '8'
end

if old_horaires != new_horaires && (DateTime.now.hour > 8 && DateTime.now.hour < 20)
  url = URI.parse('https://api.pushover.net/1/messages.json')
  req = Net::HTTP::Post.new(url.path)
  req.set_form_data({
                      token: 'adyr4aatejcfqwsfdqpoukaype55sa',
                      user: 'u82d7fj59gixejcgmrx489oeucp4c1',
                      message: "La Salle vient d'être reservé de #{DateTime.parse(new_horaires.last[0]).strftime("%H:%m")} à #{DateTime.parse(new_horaires.last[1]).strftime("%H:%m")}",
                    })
  res = Net::HTTP.new(url.host, url.port)
  res.use_ssl = true
  res.verify_mode = OpenSSL::SSL::VERIFY_PEER
  res.start { |http| http.request(req) }
end

CSV.open(csv_file, 'wb') do |csv|
  new_horaires.each { |horaire| csv << [horaire[0], horaire[1]] }
end
