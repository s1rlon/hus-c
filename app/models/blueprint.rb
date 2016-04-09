class Blueprint < ActiveRecord::Base

  @material_efficiency = 0
  @time_efficiency = 0

  attr_accessor :price_options, :material_efficiency, :time_efficiency, :runs

  serialize :activities, Hash

  def activities=(activities)
    self[:activities] = activities.try(:deep_symbolize_keys!)
  end

  def materials
    @materials ||= activities.try(:[], :manufacturing).try(:[], :materials) || []
  end

  def materials_buy
    @materials_buy ||= materials.reduce(0) do |a, m|
      a + m[:quantity] * (EveItem.get(m[:typeID]).try(:price, :materials, price_options) || 0)
    end
  end

  def products
    @products ||= activities.try(:[], :manufacturing).try(:[], :products) || []
  end

  def products_sell
    @products_sell ||= products.reduce(0) do |a, p|
      a + p[:quantity] * (EveItem.get(p[:typeID]).try(:price, :products, price_options) || 0)
    end
  end

  def products_volume
    @products_volume ||= products.reduce(0) { |a, p| a + p[:quantity] * (EveItem.get(p[:typeID]).try(:volume) || 0) }
  end

  def time
    @time ||= activities.try(:[], :manufacturing).try(:[], :time) || 0
  end

  def per_hour(value)
    value * 3600 / time.to_f
  end

  def profit
    products_sell - materials_buy
  end

end
