require 'twp'

describe TWP::Echo do
  it 'works, yay' do
    server = TWP::Echo::Server.new('127.0.0.1', 7654, nil)
    server.start(false)
    sleep 0.2

    client = TWP::Echo::Client.new '127.0.0.1', 7654, nil
    client.send_message :Request, "h e l l o"

    message = client.read_message
    message.name.should be == :Reply
    message.text.should be == "h e l l o"
    message.number_of_letters.should be == 5
    server.stop
  end
end
