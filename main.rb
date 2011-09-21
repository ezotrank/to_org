before do
  @current_user = AppEngine::Users.current_user
end

def admin?
  true if (AppEngine::Users.current_user && AppEngine::Users.admin?)
end

def admin!
  redirect '/' unless admin?
end

# Show all posts
get '/' do
  @posts = admin? ? BlogPage.all : BlogPage.public
  erb :index
end

# Delete post by id
delete '/post/:id' do
  redirect '/' && return unless admin?
  BlogPage.first(:id => params[:id]).destroy
  redirect '/'
end

get %r{/post/(.+)} do
  @post = BlogPage.first(:url => params[:captures])
  redirect '/' if @post.private && !admin?
  erb :show_post, :layout => false
end


# Load post from emacs
post '/post_by_emacs' do
  'wrong api key' && return if params[:api_key] != Settings.admin_api_key
  "#{params[:url]} updated" && return if (blog_page = BlogPage.first(:url => params[:blog_page][:url])) ? blog_page.update(params[:blog_page]) : false
  "#{params[:url]} created" && BlogPage.create(params[:blog_page])
end

get '/config' do
  admin!
  erb :config
end

get '/login' do
  redirect AppEngine::Users.create_login_url('/')
end

get '/logout' do
  redirect AppEngine::Users.create_login_url('/')
end
