Factory.define :wave_community, :class => Wave::Community do |wave|
  wave.slug Wave::CommunitiesController::DefaultWaveSlug
end