module ImuaActiveRecordExtension
  extend ActiveSupport::Concern

  # Add instance methods here
  def authenticate
    return true
  end

  # def to_lightning_hash(selects)
  #   if selects.empty? then selects = self.column_names.map(&:to_str) end
  #
  #   connection.select_all(select(selects).arel).each do |attrs|
  #     attrs.each_key do |attr|
  #       attrs[attr] = type_cast_attribute(attr, attrs)
  #     end
  #   end
  # end

  # Add static methods here
  module ClassMethods

    # If no selects are specified, assume to select all columns
    # TODO Only allow a select if there is a matching column
    def process_selects(selects)
      if selects.empty? then selects = self.column_names.map(&:to_str) end
      return selects
    end

    # Only allow a filter if there is a matching column
    def process_filters(filters)
      return FilterFactory.new.conditions(self.column_names.map(&:to_sym), filters)
    end

    def find_by_filters(filters, selects = [])
      selects = self.process_selects(selects)
      filters = self.process_filters(filters)
      return self.find(:all, :select => selects, :conditions => filters)
    end
  end

end

ActiveRecord::Base.send(:include, ImuaActiveRecordExtension)
