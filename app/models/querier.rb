# Querier.rb

# Once a Querier's view, domain, or query object is accessed, those objects
# get "locked in" for the lifetime of the Querier. The view object depends on
# the domain object, and the domain object depends on the query object, so
# accessing e.g. the Querier's view object, will automatically "lock in" the
# domain and query objects as well (as a prerequisite). Accessing e.g. the
# Querier's domain object, will not lock in the view object, though (not until
# the view object is accessed).
#
# ViewObject <-- DomainObject <-- QueryObject
#
# The database will only be queried once in the lifetime of a Querier, at
# the time that its domain object is first accessed (hence being "locked in").
#
# Once a view object is accessed, all of the Querier's subQuerier objects will
# have their view objects accessed and "locked in" as well.
#
# Both view and domain objects are accessed as an array of the Querier's
# klass. It's up to the caller to know whether the view/domain objects
# should have a ength of 1.

class Querier
  attr_accessor :subViewName

  # Public

  def initialize(klass)

    # TODO - Automatically instantiate child class if already defined
    # childKlass = (klass.to_s + "Querier").constantize
    # if Querier.descendants.include?(childKlass)
    #   Rails.logger.debug("******* child: #{childKlass} *******")
    #   retClass = childKlass.new(self)
    # end

    @klass = klass
    @subViewName = @klass.name.underscore.pluralize.to_sym
    @foreignKey = @klass.name.foreign_key.to_sym
    @columnNames = @klass.column_names.map(&:to_sym)
  end

  def select(viewAttributes, domainOnlyAttributes = [])
    self.set_attributes(viewAttributes, domainOnlyAttributes)
    return self
  end

  def where(conditions)
    self.set_conditions(conditions)
    return self
  end

  def set_subQueriers(subQueriers, *matchingAttributes)
    @subQueriers = subQueriers
    @subQuerierMatchingAttributes = matchingAttributes
    return self
  end


  def view
    return (@view.nil?) ? self.generate_view : @view
  end

  def domain(sortBy = [])
    if !sortBy.empty? && @sortedBy != sortBy
      if @domain.nil?
        self.generate_domain(sortBy)
      else
        @domain = @domain.sort_by { |d| d.values_at(*sortBy) }
      end
      @sortedBy = sortBy
    end
    return (@domain.nil?) ? self.generate_domain(sortBy) : @domain
  end

  def query
    return (@query.nil?) ? self.generate_query : @query
  end

  def conditions
    return (@conditions.nil?) ? self.set_conditions({}) : @conditions
  end

  def attributes
    return (@attributes.nil?) ? self.set_attributes([]) : @attributes
  end
  # Returns the values as an array of strings, so the result can be directly
  # used as a "where" condition parameter.
  def pluck(key)
    return (self.domain.map { |d| d[key].to_s }).uniq
  end


  # Protected

  # Only allow an attribute if the column exists
  def filter_attributes(attributes)
    return attributes.select { |k| @columnNames.include?(k)}
  end
  # Only allow a condition if the column exists
  def filter_conditions(conditions)
    return conditions.select { |k,v| @columnNames.include?(k) }
  end

  def generate_view(conditions = [])
    @view = []

    filterBy = []
    conditions.each do |c|
      if @columnNames.include?(c.keys.first)
        filterBy << c.keys.first
      end
    end
    new_conds = {}
    conditions.each{|c| c.map{|k,v| new_conds[k] = v}}
    conditions = new_conds.select {|k,v| filterBy.include?(k)}

    applicable_domains = []
    if filterBy.empty?
      applicable_domains = self.domain
    else
      # Remove from @domains as its read into the view
      # TODO - SubQuerier view generation won't work if nested more than once
      # TODO - WRITE UNIT TESTS FOR THIS!!
      while !self.domain(filterBy).empty?
        primary_key = conditions.keys[0]
        if conditions.keys.all? {|key| self.domain[0][key] == conditions[key]}
          applicable_domains << self.domain.shift
        elsif self.domain[0][primary_key] <= conditions[primary_key]
          self.domain.shift
        else
          break
        end
      end
    end

    applicable_domains.each do |d|
      view = d.select { |k,v| self.attributes.view.include?(k)}
      # Include any subQuerier views
      unless @subQueriers.nil?
        sqConditions = []
        sqConditions << {@foreignKey => d[:id]}
        @subQuerierMatchingAttributes.each do |key|
          if d.include?(key) and !d[key].nil?
            sqConditions << {key => d[key]}
          end
        end
        @subQueriers.each do |subQuerier|
          view[subQuerier.subViewName] = subQuerier.generate_view(sqConditions)
        end
      end
      # Add all the viewAttributes from domain object
      @view << view
    end
    return @view
  end

  def generate_domain(sortBy = [])
    @domain = []
    ActiveRecord::Base.connection.select_all(self.query).each do |obj|
      obj_domain = {}
      obj.each_key do |a|
        obj_domain[a.to_sym] = @klass.type_cast_attribute(a, obj)
      end
      # TODO - Insert sorted into the array
      @domain << obj_domain
    end
    sortBy << :id
      return @domain = @domain.sort_by { |d| d.values_at(*sortBy) }
  end

  def generate_query
    @query = @klass.where(self.conditions).select(self.attributes.all)
  end

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  # Private

  def set_attributes(viewAttributes, domainOnlyAttributes = [])
    viewAttributes = filter_attributes(viewAttributes)
    domainOnlyAttributes = filter_attributes(domainOnlyAttributes)

    # If no attributes are specified, assume to select all columns
    if viewAttributes.empty? and domainOnlyAttributes.empty?
      viewAttributes = @columnNames
    end
    # Always incorporate "id" within the domain object
    unless viewAttributes.include?(:id) or domainOnlyAttributes.include?(:id)
      domainOnlyAttributes << :id
    end

    return @attributes = AttributeSelection.new(viewAttributes, domainOnlyAttributes)
  end

  def set_conditions(conditions)
    # Always set :[class_name]_id to :id
    this_class_condition = conditions[@foreignKey]
    conditions[:id] = this_class_condition unless this_class_condition.nil?

    conditions = filter_conditions(conditions)

    return @conditions = conditions
  end

end


class AttributeSelection
  attr_accessor :view, :domain_only

  def initialize(viewAttributes, domainOnlyAttributes)
    @view = viewAttributes
    @domain_only = domainOnlyAttributes
  end

  def all
    all = []
    all += @view unless @view.nil?
    all += @domain_only unless @domain_only.nil?
    return all
  end
end
