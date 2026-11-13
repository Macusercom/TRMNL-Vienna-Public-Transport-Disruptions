# frozen_string_literal: true

require 'json'

# Run with `trmnlp test` (add `--report report` for a page of every screen it drew).
# Docs: https://github.com/usetrmnl/trmnlp/blob/main/docs/testing.md
RSpec.describe 'Vienna Public Transport Disruptions' do
  # Modelled on a real trafficInfoList answer: active disruptions on U3 and 9 (one with
  # "Voraussichtliche Dauer" and "Grund"), a weeks-old U3 construction notice, an active
  # disruption on an unmonitored line (U6) and an inactive entry without status.
  let(:traffic_info) { JSON.parse(File.read(File.join(__dir__, 'fixtures', 'traffic_info.json'))) }
  let(:api) { 'https://www.wienerlinien.at/ogd_realtime/trafficInfoList*' }
  let(:mocks) { { api => { json: traffic_info } } }
  let(:custom_fields) { { wl_lines: 'U3,9', wl_sort: 'time', wl_compact: 'off' } }
  let(:now) { traffic_info.dig('message', 'serverTime') }

  # Every view on TRMNL OG (1-bit, 2-bit, portrait) and TRMNL X (landscape, portrait), a failing
  # API and every select option, checked for page errors and leaked values.
  it_behaves_like 'a publishable recipe'

  def draw(fields = {}, mocks: self.mocks)
    trmnl.render(mocks:, now:, custom_fields: custom_fields.merge(fields))
  end

  it 'lists the newest disruption on a monitored line first' do
    screen = draw

    expect(screen).to have_text('Fahrtbehinderung')
    expect(screen).to have_text('Voraussichtliche Dauer: bis ca')
    expect(screen).not_to have_text('Rettungseinsatz')
    expect(screen).not_to have_text('Aufzug')
  end

  it 'hides disruptions by keyword and by age' do
    u3_only = { wl_lines: 'U3', wl_compact: 'all' }

    expect(draw(u3_only)).to have_text('Bauarbeiten')
    expect(draw(u3_only.merge(wl_exclude: 'bauarbeiten'))).not_to have_text('Bauarbeiten')
    expect(draw(u3_only.merge(wl_max_age: '30'))).not_to have_text('Bauarbeiten')
    expect(draw(u3_only.merge(wl_max_age: '30'))).to have_text('Betriebsstörung')
  end

  it 'gives the all-clear when no monitored line is disrupted' do
    quiet = traffic_info.merge('data' => { 'trafficInfos' => [] })
    screen = draw(mocks: { api => { json: quiet } })

    expect(screen).to have_text('Keine Störungen')
    expect(screen).to have_text('U3 · 9 fahren planmäßig')
  end

  it 'points at the settings when no line is configured' do
    expect(draw({ wl_lines: '' })).to have_text('Keine Linien ausgewählt')
  end
end
