<img src="images/icon.png" alt="icon" height="100">

# TRMNL Vienna Public Transport Disruptions
<img src="images/image1.png" alt="Image 1" width="400"> <img src="images/image2.png" alt="Image 2" width="400">


A TRMNL plug-in to check for Vienna public transport disruptions by fetching https://www.wienerlinien.at/ogd_realtime/trafficInfoList?relatedLine using the added public transport lines.

<a href="https://trmnl.com/recipes/250757">
  <img src="/images/trmnl-badge-show-it-on-dark.svg" alt="TRMNL" width="120">
</a>

## Settings

| Field | Purpose |
|---|---|
| Wiener Linien Public Transport Lines | One line per field, e.g. `U1`, `49`, `8A` |
| Stop IDs (optional) | Narrow disruptions down to specific stops |
| Excluded Keywords (optional) | Hide disruptions whose title or description contains one of these words, e.g. `Bauarbeiten` |
| Maximum Age (days, optional) | Hide long-running disruptions that started more than this many days ago |
| Sort Order | Newest first, or grouped by the order the lines were entered |
| Compact Mode | Show line, title and start time only — off, half and quadrant layouts only, or all layouts |

## Development

The templates live in `src/` and are deployed by the GitHub Actions workflow: every push to `main` runs `trmnlp lint` and `trmnlp test`, and only when both pass `trmnlp push`, which updates the plugin referenced by the `id` in `src/settings.yml`. Edit the plugin here rather than in the TRMNL web editor, otherwise changes are overwritten on the next push.

`tests/plugin_spec.rb` renders every view on TRMNL OG (1-bit and 2-bit, landscape and portrait) and TRMNL X (landscape and portrait), with every select option and with a failing API, against the sample answer in `tests/fixtures/traffic_info.json`. It needs Firefox, so the simplest way to run it is the trmnlp Docker image:

```sh
docker run --rm -v "$PWD":/plugin trmnl/trmnlp:v0.34.1 test --report Debug/report
```

The report in `Debug/report/` shows every screen the tests drew; CI uploads it as the `trmnlp-report` artifact.

For a local preview install [trmnlp](https://github.com/usetrmnl/trmnlp) and run:

```sh
gem install trmnl_preview
trmnlp serve   # http://localhost:4567
```

Custom field values for the local server are preset in `.trmnlp.yml`, which is not uploaded to TRMNL. Note that trmnlp percent-encodes commas in the polling URL, which the Wiener Linien API reads as a single unknown line — preview one line at a time.

The lint step tolerates exactly one finding: the Wiener Linien logo is embedded from Wikimedia, which answers 403 to requests from CI runners, so `trmnlp lint` always reports that image as unreachable. Any second finding fails the build.

## Credits
Data provided by <a href="https://www.wienerlinien.at/open-data">Wiener Linien</a>  
Image loaded via <a href="https://www.wikipedia.org/">Wikipedia.org</a>
