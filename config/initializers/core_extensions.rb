Dir.glob(Rails.root.join('lib/core_extensions/**/*.rb')).sort.each do |filename|
  require filename
end
