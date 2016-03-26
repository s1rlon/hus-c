class Blueprint < ActiveRecord::Base
  serialize :activities, Hash

  def activities=(activities)
    self[:activities] = activities.try(:deep_symbolize_keys!)
  end

  def materials
    activities.try(:[], :manufacturing).try(:[], :materials) || []
  end

  def cost
    materials.reduce(0) do |a, m|
      a + m[:quantity] * (EveItem.get(m[:typeID]).try(:price) || 0)
    end
  end

  def products
    activities.try(:[], :manufacturing).try(:[], :products) || []
  end

  def sell_for
    products.reduce(0) do |a, p|
      a + p[:quantity] * (EveItem.get(p[:typeID]).try(:price) || 0)
    end
  end
end
