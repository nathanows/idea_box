require 'yaml/store'

class IdeaStore
  def self.database
    return @database if @database

    @database ||= YAML::Store.new "db/ideabox"
    @database.transaction do
      @database['ideas'] ||= []
    end
    @database
  end

  def self.create(data)
    tags = data["tags"].split(", ") unless data["tags"].is_a? Array
    data["tags"] = tags unless data["tags"].is_a? Array
    database.transaction do
      database['ideas'] << data
    end
  end

  def self.raw_ideas
    database.transaction do |db|
      db['ideas'] || []
    end
  end

  def self.all
    raw_ideas.map.with_index do |data, i|
      Idea.new(data.merge("id" => i))
    end
  end

  def self.cust_sort(param)
    case param
    when "title" then all.sort_by { |idea| idea.send(param).downcase }
    when "rank"  then all.sort_by { |idea| idea.send(param) }.reverse
    when "tags"  then all.sort_by { |idea| idea.send(param).first.to_s.downcase }
    else              all.sort_by { |idea| idea.send(param) }
    end
  end

  def self.filter(tag)
    all.select { |idea| idea.tags.include?(tag) }
  end

  def self.tags
    unique_tags = []
    raw_ideas.each do |idea|
      new_idea = Idea.new(idea)
      new_idea.tags.each do |tag|
        unique_tags << tag unless unique_tags.include?(tag)
      end
    end
    unique_tags
  end

  def self.delete(id)
    database.transaction do
      database['ideas'].delete_at(id)
    end
  end

  def self.find(id)
    raw_idea = find_raw_idea(id)
    Idea.new(raw_idea.merge("id" => id))
  end

  def self.find_raw_idea(id)
    database.transaction do
      database['ideas'].at(id)
    end
  end

  def self.update(id, data)
    tags = data["tags"].split(", ") unless data["tags"].is_a? Array
    data["tags"] = tags unless data["tags"].is_a? Array
    database.transaction do
      database['ideas'][id] = data
    end
  end
end
