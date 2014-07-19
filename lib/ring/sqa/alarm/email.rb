require 'net/smtp'

module Ring
class SQA
class Alarm

  class Email
    SERVER = 'localhost'

    def send msg
      @msg = msg
      @to   = CFG[:email_to]
      @from = CFG[:email_from]
      send_email compose_email
    end

    private

    def initialize
    end

    def compose_email
      mail = []
      mail << 'From: '     + @from
      mail << 'To: '       + @to
      mail << 'Subject: '  + @msg
      mail << 'List-Id: '  + 'ring-sqa <sqa.ring.nlnog.net>'
      mail << 'X-Mailer: ' + 'ring-sqa'
      mail.join("\n")
    end

    def send_email email
      Net::SMTP.start('localhost') do |smtp|
        smtp.send_message email, @from, @to
      end
    end
  end

end
end
end
