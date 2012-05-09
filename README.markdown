# Quick Omniauth-Facebook Demo


Omniauth is an easy way to add authentication to your Rails app if you don't need username/password. In this example I demo how to add Facebook authentication to your app. 

This tutorial refers to the example code I used to give my CA lightning talk on omniauth-facebook. If you want a more in-depth tutorial then I highly recommend the following resources.

1. Railscasts - http://railscasts.com/episodes/241-simple-omniauth

2. RailsApps Omniauth-Mongoid Tutorial - http://railsapps.github.com/tutorial-rails-mongoid-omniauth.html (just ignore the Mongoid and testing part if you want to focus on omniauth)

3. The gem homepage of course! - https://github.com/mkdynamic/omniauth-facebook


## Getting Started


1. At the command prompt, create a new Rails application:
       <tt>rails new myapp</tt> (where <tt>myapp</tt> is the application name)

2. Change directory to <tt>myapp</tt> and start the web server:
       <tt>cd myapp; rails server</tt> (run with --help for options)

3. Add `gem omniauth-facebook` to your gemfile.

4. Run `bundle install`

You should now have omniauth-facebook ready to go. 


## Generate a User Model

1. In this case we will generate a User model with 4 attributes. Provider will be whichever strategy we are going to use (in this case Facebook), uid is the id we get back from that provider. We select name and email as the other attributes to fulfill the minimum requirements to get our app working. 

  ```rails g model User provider:string uid:string name:string email:string```
  
Then

  ```rake db:migrate```
  
## Set up Authentication

1. Create a new file called ```omniauth.rb``` in the ```config/initializers``` directory

2. Copy this code into your ```omniauth.rb``` file:

        Rails.application.config.middleware.use OmniAuth::Builder do
          provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
                   :scope => 'email,user_birthday,read_stream', :display => 'popup'
        end


  
\* You may want to remove the 'ENV' portion along with the [] around your Facebook key and secret.
\* You will need to define scope if you want to access additional permissions from Facebook
\* You will also need the to pass in ```:display => 'popup'``` as an additional parameter if you want to create a popup on signin. However, note you will have to write the additional javascript to make this happen!

3. Create a new app at http://developers.facebook.com/ (remember to enter http://localhost:3000) as your site URL

## Generate a Sessions Controller

1. We are going to want to use sessions to store information about when a user is logged in and signed out. Therefore we need to:

    rails g controller sessions
  
2. Within the sessions controller we can create a ```create``` action like so:

    def create
      raise request.env["omniauth.auth"].to_yaml
    end
  
\* This will output in YAML format the hash we get back from Facebook. 

## Create Some Routes

1. Add these routes to ```config/routes.rb```

    match '/auth/:provider/callback' => 'sessions#create'
  
    match '/signout' => 'sessions#destroy', :as => :signout
  
    match '/signin' => 'sessions#new', :as => :signin
  
The first route defined above will direct the callback from Facebook to the sessions#create action. If you think
about it in terms of hash being returned from Facebook then you can see how we will set up the create action to take in that hash and check if a user exists or create a new user using that information. 

## OK time to give it a test run...

1. Hit ```rails s``` and fire up your browser to http://localhost:3000

2. Enter in the URL http://localhost:3000/auth/facebook

This should try to login with Facebook, and upon acceptance as a user, you should see a hash of information about the user displayed on your screen. 

## Store User Data in User Object

1. Add this code to your ```User.rb``` file

    def self.create_with_omniauth(auth)
      create! do |user|
        user.provider = auth['provider']
        user.uid = auth['uid']
        if auth['info']
          user.name = auth['info']['name'] || ""
          user.email = auth['info']['email'] || ""
        end
      end
    end
  
\* When called this method will try and create a new user using the values of the keys in the ```auth``` hash which we will define in the sessions controller next.

## Modify Sessions Controller

1. Replace the existing create action with the code below:

    def create
      auth = request.env["omniauth.auth"]
      user = User.where(:provider => auth['provider'], 
                        :uid => auth['uid']).first || User.create_with_omniauth(auth)
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Signed in!"
    end

\* This assigns the hash from Facebook into an ```auth``` variable. It then checks if a user exists and if not, it calls the ```create_with_omniauth(auth)``` method we defined in the ```User``` model. Lastly, it sets the ```session[:user_id]``` to the users id and redirects back to the homepage with a notice of "Signed in!".

2. Add a new action to your sessions controller:

    def new
      redirect_to '/auth/facebook'
    end
  
\* Remember in the routes we defined a named routed called ```signin``` which was linked to the 'sessions#new' action? Now we can use that named routes e.g. signin_path which will invoke the ```new``` action and redirect to ```/auth/facebook``` to begin the authentication process.

3. Add a destroy action to your sessions controller:

    def destroy
      reset_session
      redirect_to root_url, notice => 'Signed out'
    end
  
\* While we are not going to use this action in this example, this will enable you to signout users. Similar to above when you create a link using the signout_path it will invoke this action which will wipe all the information out of the session and redirect to the homepage, thus signing the user out.

## Last Step - Showing it off

Create a homepage, and show the flash message as proof we are signed in. 

1. Remove old homepage

    rm public/index.html.erb
  
2. Create home controller with index action

    rails g controller home index
  
3. Configure routes

    root :to => 'home#index'
  
4. Edit 'index.html.erb'

    <h1>Homepage</h1>
  
    <ul>
    <% flash.each do |key, msg| %>
      <%= content_tag :li, msg, id: key %>
    <% end %>
    </ul>
  
    <p><%= link_to 'Sign in with Facebook', signin_path %></p>
  
5. Hit ```rails s``` and check it works! 

6. You can also enter ```rails c``` at the command line and then ```User.last``` to see if a user object was stored in your database table. 

## Done!

Hope you found this useful. As mentioned before I recommend checking out the official tutorials, particularly the Rails Apps tutorial which goes into much more depth. 

If you have any questions just shoot me an email at wintle.ralph [at] gmail.com
  
  
  
  
  
  