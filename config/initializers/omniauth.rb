Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '331992553536283', '18cf03bd12b666be34bad841d21313b6',
           :display => 'popup'
end