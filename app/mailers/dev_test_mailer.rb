class DevTestMailer < ApplicationMailer
  def test_email
    mail(
      to: 'phnanda@umass.edu',
      from: 'hackher413@gmail.com',
      subject: 'SES Test Email',
      body: 'Hello from HackHer413 via AWS SES!'
    )
  end
end
