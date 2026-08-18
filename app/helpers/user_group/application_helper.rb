module UserGroup
  module ApplicationHelper
    # http://www.candland.net/2012/04/17/rails-routes-used-in-an-isolated-engine/
    def method_missing method, *args, &block
      # puts "LOOKING FOR ROUTES #{method}"
      if method.to_s.end_with?('_path') or method.to_s.end_with?('_url')
        if main_app.respond_to?(method)
          main_app.send(method, *args)
        else
          super
        end
      else
        super
      end
    end

    def respond_to?(method, include_all = false)
      if method.to_s.end_with?('_path') or method.to_s.end_with?('_url')
        main_app.respond_to?(method, include_all) || super
      else
        super
      end
    end
  end
end
