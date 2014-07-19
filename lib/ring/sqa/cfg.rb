module Ring
  class SQA
    CFG = {
      address: Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3],
      debug:       false,
      email_to:   'saku@ytti.fi',
      email_from: 'saku@ytti.fi',
      db:         '/tmp/ring-sqa.db',
    }
  end
end
