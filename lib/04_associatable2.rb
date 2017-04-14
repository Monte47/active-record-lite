require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...
  end
end

# self.assoc_options[name] = BelongsToOptions.new(name, options)
#
#  define_method(name) do
#    options = self.class.assoc_options[name]
#
#    key_val = self.send(options.foreign_key)
#    options
#      .model_class
#      .where(options.primary_key => key_val)


# self.assoc_options[name] =
# HasManyOptions.new(name, self.name, options)
#
# define_method(name) do
#   options = self.class.assoc_options[name]
#
#   key_val = self.send(options.primary_key)
#   options
#   .model_class
#   .where(options.foreign_key => key_val)
