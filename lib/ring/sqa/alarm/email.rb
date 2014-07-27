require 'net/smtp'

module Ring
class SQA
class Alarm

  class Email
    SERVER = 'localhost'

    def send msg
      @from    = CFG.email.from
      @to      = [CFG.email.to].flatten
      prefix   = CFG.email.prefix? ? CFG.email.prefix : ''
      @subject = prefix + msg[:short]
      @body    = msg[:long]
      send_email compose_email
    rescue => error
      Log.error "Email raised '#{error.class}' with message '#{error.message}'"
    end

    private

    def compose_email
      mail = []
      mail << 'From: '     + @from
      mail << 'To: '       + @to.join(', ')
      mail << 'Subject: '  + @subject
      mail << 'List-Id: '  + 'ring-sqa <sqa.ring.nlnog.net>'
      mail << 'X-Mailer: ' + 'ring-sqa'
      mail << ''
      mail = mail.join("\n")
      mail+@body
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
