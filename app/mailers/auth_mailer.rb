class AuthMailer < ActionMailer::Base
  default from: "no-reply@dri.ie"

  def pending_mail(managers, user, url)
    if !managers.nil? && !managers.empty?
      @user = user
      @url = url
      managers.each do |email|
        mail(to: email, subject: 'Pending read requests')
      end
    end
  end

  def approved_mail(user, group, collection)
    @user = user
    @group = group
    @collection = collection
    mail(to: @user.email, subject: 'Read request Approved')
  end

end
