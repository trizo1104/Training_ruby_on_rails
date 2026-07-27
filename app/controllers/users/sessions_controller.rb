module Users
  class SessionsController < Devise::SessionsController
    layout "authentication"
  end
end
