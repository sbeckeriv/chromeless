require "rubygems"
require "eventmachine"
require "em-websocket"
BAD_IMAGE="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAhsAAAEvCAYAAADsJAObAAAFI0lEQVR4nO3WQQkAMAzAwPo3vaoIg3KnIM/MAwAIze8AAOA2swEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApBbIy3EfLVDdxQAAAABJRU5ErkJggg=="
require 'digest/md5'
require "uri"
require "base64"
EventMachine.run {

  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
  ws.onopen {
    puts "WebSocket connection open"

    # publish message to the client
    ws.send "beck:http://woot.com"
    ws.send "beck:http://amazon.com"
    ws.send "beck:http://google.com"
    
  }

  ws.onclose { puts "Connection closed" }
  ws.onmessage { |msg|
    message = msg.split("||||")
    case message[0]

    when "thunbnail"
      unless message[2]==BAD_IMAGE
        uri = URI.parse(message[1])
        url_md5= Digest::MD5.hexdigest(message[1])
        host_md5 = Digest::MD5.hexdigest(uri.host)
        puts message[1],url_md5,host_md5          
        data= message[2].sub("data:image/png;base64,","")
        File.open(File.join("","Users","becker","trash","pics",url_md5+Time.now.to_i.to_s+".png"),"wb"){|f|f.write(Base64.decode64(data))} 
      end
    end

  }
  end
}

