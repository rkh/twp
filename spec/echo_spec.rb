require 'twp'

describe TWP::Echo do
  it 'works, yay' do
    pid = fork { TWP::Echo::Server.new('127.0.0.1', 7654).start }
    sleep 0.2

    client = TWP::Echo::Client.new '127.0.0.1', 7654
    client.send_message :Request, "hello"

    message = client.read_message
    message.name.should be == :Reply
    message.text.should be == "hello"
    message.number_of_letters.should be == 5
    Process.kill("KILL", pid)
  end
end
