require 'idea_box'

class IdeaBoxApp < Sinatra::Base
  set :method_override, true
  set :root, 'lib/app'

  get '/' do
    erb :index, locals: { ideas: IdeaStore.all.sort,
                          idea: Idea.new(params),
                          tags: IdeaStore.tags }
  end

  get '/sort/:param' do |param|
    erb :index, locals: { ideas: IdeaStore.cust_sort(param),
                          idea: Idea.new(params),
                          tags: IdeaStore.tags }
  end

  get '/filter/:tag' do |tag|
    erb :index, locals: { ideas: IdeaStore.filter(tag),
                          idea: Idea.new(params),
                          tags: IdeaStore.tags }
  end


  post '/' do
    IdeaStore.create(params[:idea])
    redirect '/'
  end

  delete "/:id" do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  get '/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, locals: { idea: idea }
  end

  put '/:id' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.edit(params[:idea])
    IdeaStore.update(id.to_i, idea.to_h)
    redirect '/'
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update(id.to_i, idea.to_h)
    redirect '/'
  end

  post '/:id/add_tag' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.add_tag(params[:idea]["tag"])
    IdeaStore.update(id.to_i, idea.to_h)
    redirect '/'
  end

  not_found do
    erb :error
  end
end
