SETTING_GROUP_DEFAULT = 'registered'
SETTING_GROUP_ADMIN = 'admin'
SETTING_ORDER_USER = 'second_name'
SETTING_ORDER_GROUP = 'name'
PROFILE_VIEW_LEVELS = { 0 => 'private', 1 => 'public', 2 => 'registered' }
SETTING_PROFILE_INDEX_VIEW_LEVELS = [1 , 2]
#If set to 0 it never expires
SETTING_TOKEN_EXPIRY_DAYS = 0
SETTING_PROFILE_GRAVATAR_ID="gravatar"
SETTING_PROFILE_DEFAULT_PHOTO="default_photo.jpg"

#Paginator settings
Kaminari.configure do |config|
  config.default_per_page = 5
  # config.max_per_page = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
end