# Querier.rb

# Once a Querier's view, domain, or query object is accessed, those objects
# get "locked in" for the lifetime of the Querier. The view object depends on
# the domain object, and the domain object depends on the query object, so
# accessing e.g. the Querier's view object, will automatically "lock in" the
# domain and query objects as well (as a prerequisite). Accessing e.g. the
# Querier's domain object, will not lock in the view object, though (not until
# the view object is accessed).
#
# ViewObject --> DomainObject --> QueryObject
#
# The database will only be queried once in the lifetime of a Querier, at
# the time that its domain object is first accessed (hence being "locked in").

class Querier
  attr_accessor :subViewName

  # Public

  def initialize(classType)
    @classType = classType
    @subViewName = @classType.name.underscore.pluralize.to_sym
    @foreignKey = @classType.name.foreign_key.to_sym
    @columnNames = @classType.column_names.map(&:to_sym)
  end

  def select(viewAttributes, domainOnlyAttributes = [])
    self.set_attributes(viewAttributes, domainOnlyAttributes)
    return self
  end

  def where(conditions)
    self.set_conditions(conditions)
    return self
  end

  def set_subQueriers(*subQueriers)
    @subQueriers = subQueriers
    return self
  end


  def view
    return (@view.nil?) ? self.generate_view : @view
  end

  def domain
    return (@domain.nil?) ? self.generate_domain : @domain
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


  # Protected

  # Only allow an attribute if the column exists
  def filter_attributes(attributes)
    return attributes.select { |k| @columnNames.include?(k)}
  end
  # Only allow a condition if the column exists
  def filter_conditions(conditions)
    return conditions.select { |k,v| @columnNames.include?(k) }
  end

  def generate_view(conditions = {})
    @view = []

    applicable_domains = []
    if conditions.empty?
      applicable_domains = self.domain
    else
      applicable_domains = self.domain.select {|d| conditions.keys.any? {|key| d[key] == conditions[key]}}
    end

    applicable_domains.each do |d|
      view = {}
      # Include any subQuerier views
      unless @subQueriers.nil? 
        @subQueriers.each do |subQuerier|
          conditions = {}
          conditions[@foreignKey] = d[:id]
          view[subQuerier.subViewName] = subQuerier.generate_view(conditions)
        end
      end
      # Add all the viewAttributes from domain object
      view = view.merge(d.select { |k,v| self.attributes.view.include?(k)})
      @view << view
    end

    # TODO - Remove applicable_domains from self.domain once pushed into a view object?
    return @view
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

  def generate_domain
    @domain = []
    ActiveRecord::Base.connection.select_all(self.query).each do |obj|
      obj_domain = {}
      obj.each_key do |a|
        obj_domain[a.to_sym] = @classType.type_cast_attribute(a, obj)
      end
      @domain << obj_domain
    end
    return @domain
  end

  def generate_query
    @query = @classType.where(self.conditions).select(self.attributes.all)
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
