require "rubygems"
require "eventmachine"
require "em-websocket"
require 'digest/md5'
require "uri"
require "base64"
require "mysql"
require "pp"

BAD_IMAGE="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAhsAAAEvCAYAAADsJAObAAAFI0lEQVR4nO3WQQkAMAzAwPo3vaoIg3KnIM/MAwAIze8AAOA2swEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApBbIy3EfLVDdxQAAAABJRU5ErkJggg=="
last_id=nil
def get_next_url(last_id)


end
include EventMachine::Deferrable

$servers = Hash.new

class ShotServer 
  FILE_STORE=File.join("","Users","becker","trash","pics")
  TEMP_FILE_STORE=""
  attr_accessor :channel,:queue,:sid,:socket
  def initialize(ws)
    @queue = []
    @socket=ws
    begin
      @sid = Digest::MD5.hexdigest(@socket.__id__.to_s)
    rescue Exception=>e
      pp e
    end
  end

  def add_site(site)
    @queue.push(site)
    if(@queue.size<=20)
      @socket.send("beck:"+site)
    end
  end

  def remove_site(site,data)
    save_image(site,data)
    @queue.delete(site)
  end

  def save_image(site,data)
    uri = URI.parse(site)
    url_md5= Digest::MD5.hexdigest(site)
    host_md5 = Digest::MD5.hexdigest(uri.host)
   # puts site,url_md5,host_md5          
    data.sub!("data:image/png;base64,","")
  #  pp data
    File.open(File.join(FILE_STORE,url_md5+Time.now.to_i.to_s+".png"),"wb"){|f|f.write(Base64.decode64(data))} 
  end
  
  def class.send_all(data)
    $servers.each{|k,v| v.socket.send data}
  end

end

#Thread.new do
  begin
  EventMachine.run {
 module KeyboardInput
    include EM::Protocols::LineText2
    def receive_line data
      puts "Console input: #{data}"
      ShotServer.send_all(data)
    end
  end
  EM.open_keyboard(KeyboardInput)
    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen {
      #puts "WebSocket connection open"
      ss = ShotServer.new(ws)
      server = $servers[ss.sid.to_s] = ss

      ws.send "ssid:"+ss.sid.to_s
      # publish message to the client
      server.add_site("http://woot.com")
      server.add_site("http://amazon.com")
      server.add_site("http://google.com")
      # server.add_site("http://woot.com")

    }

    ws.onclose { puts "Connection closed" }
    ws.onmessage { |msg|
      message = msg.split("||||")
      ssid = message.shift
      #pp ssid
      server = $servers[ssid]
      case message[0]

      when "thunbnail"

        unless message[2]==BAD_IMAGE
          server.remove_site(message[1],message.last)
          
        end
      end

    }
    end
  }
  rescue Exception=>e
    pp e
  end
#end
=begin
class MyWebSocket < EventMachine::WebSocket::Connection
  def initialize(options={})
    super
  end

  def open
    puts "New client"
    @@clients ||= []
    
    #@@clients.each do |c|
    #  c.send "We have a new client"
    #end
    ss = ShotServer.new(self)
    @@clients << ss
    send ss.sid
    send "beck:http://google.com"
  end

  def message(msg)
    puts "Message: #{msg}"
    
    #@@clients.each do |c|
    #  if c == self
    
    #c.send "You said #{msg}"
    #  else
    #    c.send "I heard #{msg}"
    #  end
    #end
  end
  
  def close
    puts "WebSocket closed"
    #@@clients.delete self
    #MyWebSocket.send_to_all "We lost a friend"
  end
  
  def self.send_to_all(msg)
    @@clients ||= []
    @@clients.each do |c|
      c.send msg
    end
  end
end

EM.run do
  EventMachine.start_server("0.0.0.0", 8080, MyWebSocket)
  
  EventMachine::PeriodicTimer.new(2) do
    puts "the time is #{Time.now}"
#    MyWebSocket.send_to_all(Time.now)
  end
  
  module KeyboardInput
    include EM::Protocols::LineText2
    def receive_line data
      puts "Console input: #{data}"
      MyWebSocket.send_to_all(data)
    end
  end
  EM.open_keyboard(KeyboardInput)
end
=end
