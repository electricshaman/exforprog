use Mix.Config

config :p31_karvonen_heart_rate,
  intensity_scale_start: 5,
  intensity_scale_end: 95,
  intensity_scale_step: 5,
  invalid_input_attempts: 5

#import_config "#{Mix.env}.exs"
