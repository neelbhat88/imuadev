class FilterFactory

  # TODO Is this safe from injection?
  def conditions(applicable_filters_array, filters_hash)
    conditions = []
    arguments = {}

    applicable_filters = filters_hash.select { |k,v| applicable_filters_array.include?(k) }

    applicable_filters.keys.each do |f_key|
      # Example of what this is doing:
      # conditions << 'time_unit_id = :time_unit_id'
      # arguments[:time_unit_id] = timeUnitId

      f_str = f_key.to_s
      conditions << f_str + ' = :' + f_str
      arguments[f_key] = applicable_filters[f_key]
    end

    allConditions = conditions.join(' AND ')
    return [allConditions, arguments]
  end

end
