class Querier
  attr_accessor :classType

  # Public

  def initialize(classType)
    @classType = classType
  end

  def select(viewAttributes, domainOnlyAttributes = [])
    self.set_attributes(viewAttributes, domainOnlyAttributes)
    return self
  end

  def where(conditions)
    self.set_conditions(conditions)
    return self
  end

  def set_sub_models(*subModels)
    @subModels = subModels
    return self
  end


  def domain
    return (@domain.nil?) ? self.generate_domain : @domain
  end

  def view
    return (@view.nil?) ? self.generate_view : @view
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
    return attributes.select { |k| @classType.column_names.map(&:to_sym).include?(k)}
  end
  # Only allow a condition if the column exists
  def filter_conditions(conditions)
    return conditions.select { |k,v| @classType.column_names.map(&:to_sym).include?(k) }
  end

  # Private

  def set_attributes(viewAttributes, domainOnlyAttributes = [])
    viewAttributes = filter_attributes(viewAttributes)
    domainOnlyAttributes = filter_attributes(domainOnlyAttributes)

    # If no attributes are specified, assume to select all columns
    if viewAttributes.empty? and domainOnlyAttributes.empty?
      viewAttributes = @classType.column_names.map(&:to_sym)
    end
    # Always incorporate "id" within the domain object
    unless viewAttributes.include?(:id) or domainOnlyAttributes.include?(:id)
      domainOnlyAttributes << :id
    end

    return @attributes = AttributeSelection.new(viewAttributes, domainOnlyAttributes)
  end

  def set_conditions(conditions)
    # Always set :[class_name]_id to :id
    this_class_condition = conditions[@classType.name.foreign_key.to_sym]
    conditions[:id] = this_class_condition unless this_class_condition.nil?

    conditions = filter_conditions(conditions)

    return @conditions = conditions
  end

  def generate_view
    @view = []
    self.domain.each do |d|
      # Include view attributes only
      view = d.select { |k,v| self.attributes.view.include?(k)}
      # Include any subModel views
      unless @subModels.nil? 
        @subModels.each do |subModel|
          category = subModel.classType.name.underscore.pluralize.to_sym
          view[category] = subModel.domain.select {|a| a[@classType.name.foreign_key.to_sym] == d[:id]}
        end
      end
      @view << view
    end
    return @view
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
