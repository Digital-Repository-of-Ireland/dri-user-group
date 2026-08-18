class AuthMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def pending_mail(managers, user, url)
    Rails.logger.debug("[AUTH MAILER] sending mail to #{managers}")
    return unless !managers.nil? && !managers.empty?

    @user = user
    @url = url
    @managers = managers
    mail(to: @managers, subject: t('user_groups.mailers.pending.subject'))
  end

  def approved_mail(user, group, collection)
    @user = user
    @group = group
    @collection = collection
    mail(to: @user.email, subject: t('user_groups.mailers.approved.subject'))
  end

  def rejected_mail(user, group, collection)
    @user = user
    @group = group
    @collection = collection
    mail(to: @user.email, subject: t('user_groups.mailers.rejected.subject'))
  end

  def removed_mail(user, group, collection)
    @user = user
    @group = group
    @collection = collection
    mail(to: @user.email, subject: t('user_groups.mailers.removed.subject'))
  end
end
