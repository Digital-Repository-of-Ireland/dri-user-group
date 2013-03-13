SETTING_DEFAULT_GROUP = 'registered'
SETTING_ADMIN_GROUP = 'admin'
SETTING_USER_ORDER = 'second_name'
SETTING_GROUP_ORDER = 'name'
PROFILE_VIEW_LEVELS = { 0 => 'private', 1 => 'public', 2 => 'registered' }
SETTING_PROFILE_INDEX_VIEW_LEVELS = [1 , 2]

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