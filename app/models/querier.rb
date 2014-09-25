class Querier

  # Public
  def initialize(viewAttributes, domainOnlyAttributes = [])
    set_attributes(viewAttributes, domainOnlyAttributes)
  end

  def set_attributes(viewAttributes, domainOnlyAttributes = [])
    viewAttributes = filter_attributes(viewAttributes)
    domainOnlyAttributes = filter_attributes(domainOnlyAttributes)

    # If no attributes are specified, assume to select all columns
    if viewAttributes.empty? and domainOnlyAttributes.empty?
      viewAttributes = self.column_names.map(&:to_sym)
    end
    # Always incorporate "id" within the domain object
    unless viewAttributes.include?(:id) or domainOnlyAttributes.include?(:id)
      domainOnlyAttributes << :id
    end

    @attributes = AttributeSelection.new(viewAttributes, domainOnlyAttributes)
  end

  def set_conditions(conditions)
    @conditions = self.filter_conditions(conditions)
  end

  def set_sub_models(*subModels)
    @subModels = subModels
  end

  def set_sub_hash(key, hash)
    if @subHashes.nil? then @subHashes = {} end
    @subHashes[key] = hash
  end


  def domain
    return (@domain.nil?) ? self.generate_domain() : @domain
  end

  def view
    return (@view.nil?) ? self.generate_view() : @view
  end

  def query
    return (@query.nil?) ? self.generate_query() : @query
  end

  def conditions
    if @conditions.nil? then self.set_conditions({}) end
    return @conditions
  end

  def attributes
    if @attributes.nil? then self.set_attributes([]) end
    return @attributes  
  end

  def column_names
    if @column_names.nil?
      Rails.logger.debug("Error - @column_names needs to be set by child class")
      @column_names = {}
    end
    return @column_names
  end



  def find_by_filters2(filters, selects = [])
    self.set_conditions(filters)
    self.set_attributes(selects)

    self.generate_view()

    Rails.logger.debug("****** viewAttributes: #{self.attributes.view} *******")
    Rails.logger.debug("****** domainAttributes: #{self.attributes.domain_only} *******")
    Rails.logger.debug("****** domain: #{@domain} *******")
    Rails.logger.debug("****** view: #{@view} *******")

    return self.do_find()
  end

  def do_find(doProcessing = true)
    if doProcessing
      self.process_attributes()
      self.process_conditions()
    end

    Rails.logger.debug("****** processedAttributes: #{@processedAttributes} *******")
    Rails.logger.debug("****** processedConditions: #{@processedConditions} *******")

    result = self.find(:all, :select => @processedAttributes, :conditions => @processedConditions)
    
    return result
  end


  # Protected - to be overriden by child classes
  # TODO - Make these static

  # Only allow an attribute if the column exists
  def filter_attributes(attributes)
    return attributes.select { |k| self.column_names.map(&:to_sym).include?(k)}
  end
  # Only allow a condition if the column exists
  def filter_conditions(conditions)
    return conditions.select { |k,v| self.column_names.map(&:to_sym).include?(k) }
  end

  # Private

  def generate_view()
    @view = []
    self.domain.each do |d|
      # Include view attributes only
      view = d.select { |k,v| self.attributes.view.include?(k)}
      # Include any subModel views
      unless @subModels.nil? 
        @subModels.each do |subModel|
          category = subModel.name.underscore.pluralize.to_sym
          view[category] = subModel.view
        end
      end
      # Include any subHashes
      unless @subHashes.nil?
        view = @subHashes.merge(view)
      end
      @view << view
    end
    return @view
  end

  def generate_domain()
    @domain = []
    ActiveRecord::Base.connection.select_all(self.query).each do |obj|
      obj_domain = {}
      obj.each_key do |a|
        obj_domain[a.to_sym] = type_cast_attribute(a, obj)
      end
      @domain << obj_domain
    end
    return @domain
  end

  def generate_query()
    Rails.logger.debug("Error - generate_query needs to be overridden")
    # return @query = self.where(self.conditions).select(self.attributes.all)
  end

  def type_cast_attribute(attr_name, attributes)
    Rails.logger.debug("Error - type_cast_attribute needs to be overridden")
  end



  # If no selects are specified, assume to select all columns
  # TODO Only allow a select if there is a matching column
  def self.process_attributes()
    attributes = self.attributes.all

    if attributes.empty?
      attributes = self.column_names.map(&:to_str)
    end

    @processedAttributes = attributes

    return @processedAttributes
  end

  # Only allow a filter if there is a matching column
  def self.process_conditions()
    conditions = []
    arguments = {}

    applicable_conditions = self.conditions.select { |k,v| self.column_names.map(&:to_sym).include?(k) }
    applicable_conditions.keys.each do |f_key|
      # Example of what this is doing:
      # conditions << 'time_unit_id = :time_unit_id'
      # arguments[:time_unit_id] = timeUnitId
      f_str = f_key.to_s
      conditions << f_str + ' = :' + f_str
      arguments[f_key] = applicable_conditions[f_key]
    end

    @processedConditions = [conditions.join(' AND '), arguments]

    return @processedConditions
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

