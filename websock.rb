require "rubygems"
require "eventmachine"
require "em-websocket"
require 'digest/md5'
require "uri"
require "base64"
require "mysql"
require "pp"
require "singleton"

BAD_IMAGE="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAhsAAAEvCAYAAADsJAObAAAFI0lEQVR4nO3WQQkAMAzAwPo3vaoIg3KnIM/MAwAIze8AAOA2swEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApMwGAJAyGwBAymwAACmzAQCkzAYAkDIbAEDKbAAAKbMBAKTMBgCQMhsAQMpsAAApswEApBbIy3EfLVDdxQAAAABJRU5ErkJggg=="
class Storage
  @@last_id = nil
  include Singleton

  def self.connect()
    Mysql.connect("127.0.0.1","root","x10college","dbDMOZcopy")
  end
  @@db = self.connect()

  def db
    @@db
  end

  def get_next_url()
    row= Storage.instance.db.query("select * from thosts where id > #{@@last_id||0} limit 1").to_enum.first
    @@last_id=row.first
    row.last
  end
end
Storage.instance.get_next_url

$servers = Hash.new

class ShotServer 
  MAX_SENT = 20
  FILE_STORE=File.join("","Users","becker","trash","pics")
  TEMP_FILE_STORE=""
  attr_accessor :channel,:queue,:sid,:socket,:sent_queue
  def initialize(ws)
    @queue = []
    @sent_queue = []
    @socket=ws
    begin
      @sid = Digest::MD5.hexdigest(@socket.__id__.to_s)
    rescue Exception=>e
      pp e
    end
  end

  #add it to a queue if less then 20 are out send it right away
  def queue_site(site)
    if(@sent_queue.size <= MAX_SENT)
      pp "sent now"
      send_site(site)
    else
      pp "queued site"
      @queue.push(site)
    end
  end

  #send the first in the queue unless we give it one
  def send_site(site=nil)
    site = @queue.shift unless site
  pp "________send__"+site
   pp @queue.delete(site)
   pp @sent_queue.push(site)
    @socket.send("beck:"+site)
  end

  def remove_site(site,data)
    save_image(site,data)
  pp "________remove__"+site
   pp @queue.delete(site)
   pp @sent_queue.delete(site)

    ShotServer.fill_queue(self)
    ShotServer.trigger_send()

  end

  def save_image(site,data)
    uri = URI.parse(site)
    url_md5= Digest::MD5.hexdigest(site)
     puts site,url_md5         
    data.sub!("data:image/png;base64,","")
    #  pp data
    File.open(File.join(FILE_STORE,url_md5+".png"),"wb"){|f|f.write(Base64.decode64(data))} 
    
   
  end

  def self.send_all_servers(data)
    $servers.each{|k,v| v.socket.send data}
  end

  def self.fill_queue(server)
    (20-server.queue.size).times{
      pp "fill"+ server.sid
      site = Storage.instance.get_next_url
      server.queue_site(site)
    }

  end

  #should be mostly 1
  def self.trigger_send()
    pp "trigger"
    $servers.each{|k,v| 
      if(v.sent_queue.size < MAX_SENT && v.queue.size>0)
        (MAX_SENT-v.sent_queue.size).times{
          v.send_site()
        }
      end
    }
  end


end
#Thread.new do
begin
  EventMachine.run {
    module KeyboardInput
      include EM::Protocols::LineText2
      def receive_line data
        puts "Console input: #{data}"
        ShotServer.send_all_servers(data)
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
      10.times{
        site = Storage.instance.get_next_url
        pp site
        server.queue_site(site)
      }

    }

    ws.onclose { puts "Connection closed" }
    ws.onmessage { |msg|
      message = msg.split("||||")
      ssid = message.shift
      server = $servers[ssid]
      case message[0]

      when "thunbnail"

        unless message[2]==BAD_IMAGE
          pp message[1]
          server.remove_site(message[1],message.last)

        end
      when "ping"
        pp msg
      end

    }
  end
  }
rescue Exception=>e
  pp e
end
#end

