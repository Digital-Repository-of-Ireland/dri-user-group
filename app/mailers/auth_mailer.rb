class AuthMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def pending_mail(managers, user, url)
    if !managers.nil? && !managers.empty?
      @user = user
      @url = url
      @managers = managers
      mail(to: @managers, subject: t('user_groups.mailers.pending.subject'))
    end
  end

  def approved_mail(user, group, collection)
    @user = user
    @group = group
    @collection = collection
    mail(to: @user.email, subject: t('user_groups.mailers.approved.subject'))
  end

end
