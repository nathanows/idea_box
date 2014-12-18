require 'yaml/store'

class Idea
  include Comparable
  attr_reader :title, :description, :rank, :id, :tags

  def initialize(attributes = {} )
    @title = attributes["title"]
    @description = attributes["description"]
    @rank = attributes["rank"] || 0
    @id = attributes["id"]
    @tags = attributes["tags"] || []
  end

  def to_h
    {
      "title" => title,
      "description" => description,
      "rank" => rank,
      "tags" => tags
    }
  end

  def edit(params)
    @title = params["title"]
    @description = params["description"]
    @tags = params["tags"]
  end

  def like!
    @rank += 1
  end

  def <=>(other)
    other.rank <=> rank
  end

  def add_tag(tag)
    @tags << tag
  end
end
