# Brown Trout IPM — Site Reports

Combined model-selection + parameter-estimate reports for the Montana brown
trout streamflow/drought IPM project, plus a GitHub Pages dropdown site for
browsing them.

## Files in this bundle

| File | Purpose |
|---|---|
| `site_report_template.Rmd` | The parameterized report. Renders one site per call via `params$stream` / `params$section` / `params$data_dir`. Combines the old model-selection template (`02_site_template.Rmd`) and the parameter/findings template (`Site_Params_NEW.Rmd`) into a single narrative. |
| `render_all_sites.R` | Batch-renders every site listed in the `sites` data frame (or auto-discovered from your data directory) to `docs/<Stream>_<Section>.html` and writes `docs/sites.json` used by the dropdown. |
| `docs/index.html` | GitHub Pages landing page. Reads `sites.json`, populates a site-picker dropdown, and loads the selected site's HTML in an iframe. |

## Report structure

1. **About This Project** — 2–3 sentence project intro (edit in the Rmd to tweak).
2. **Site Overview** — river / section / model structure / year range.
3. **Model Selection Summary** — top-selected lag + quadratic structure in one table. Pointer to the appendix.
4. **Key Findings** — interpretive narrative with model diagram, equations, seasonal flow→recruitment, flow→survival, density dependence, biomass trend, and explained-variance summary.
5. **Abundance Time Series** (plotly, interactive flow overlays)
6. **Survival Time Series** (plotly, interactive flow overlays)
7. **Ricker Recruitment** — parameter table, flow-effect posteriors, simulated curves, observed flow–R/S relationship.
8. **Flow Effects on Survival** — parameter table, posteriors, observed flow–survival relationship.
9. **Explained Residual Variance** — flow vs. null model.
10. **Appendix: Full Model Selection Details** — lag inclusion bars, joint lag heatmap (global models), quadratic-across-lags panels, full combinations table.

## One-time project setup

Your project should look like this:

```
your-repo/
├── site_report_template.Rmd
├── render_all_sites.R
├── data/
│   └── ModelFits/
│       └── Brown Trout/
│           ├── BigHole.Melrose_RecLagInclusionProbQuad.csv
│           ├── BigHole.Melrose_flow.csv
│           ├── BigHole.Melrose_IndicatorVarSel_TopMod_Feb26.rds
│           ├── BigHole.Melrose_IndicatorVarSel_NullMod_resids.rds
│           └── ...
└── docs/
    ├── index.html
    └── sites.json         <- created by render_all_sites.R
```

> **Note:** The old `Site_Params_NEW.Rmd` used two params, `lag_dir` and
> `model_dir`, with inconsistent capitalization (`data/...` vs `Data/...`).
> That would break on GitHub Actions (Linux is case-sensitive). The combined
> template uses a single `data_dir` param, normalized to lowercase.

## Rendering a single site (for testing / editing)

In RStudio, open `site_report_template.Rmd` and click Knit, or from R:

```r
rmarkdown::render(
  "site_report_template.Rmd",
  output_file = "BigHole_Melrose.html",
  output_dir  = "docs",
  params = list(
    stream   = "BigHole",
    section  = "Melrose",
    data_dir = "data/ModelFits/Brown Trout"
  )
)
```

## Rendering all sites

1. Open `render_all_sites.R` and edit the `sites` tibble to list every
   `(stream, section)` combination you want in the report. (Or uncomment the
   auto-discovery block to pick them up from the `*_RecLagInclusionProbQuad.csv`
   files on disk.)
2. From the project root:

   ```
   Rscript render_all_sites.R
   ```

   This writes `docs/BigHole_Melrose.html`, `docs/BigHole_Maidenrock.html`, …
   plus `docs/sites.json`.

## Hosting on GitHub Pages

1. Commit `docs/` (and the rendered HTML files) to your repo.
2. In the repo on GitHub: **Settings → Pages → Build and deployment**, set
   **Source = Deploy from a branch**, **Branch = main**, **Folder = /docs**.
3. After a minute your site will be live at
   `https://<your-username>.github.io/<repo-name>/`.
   The dropdown will list every site in `sites.json` and load the selected
   report in-page. Reports are bookmarkable via `?site=BigHole_Melrose.html`.

### Optional: automate rendering with GitHub Actions

If your `.rds` model files are small enough to commit, you can add a workflow
that runs `Rscript render_all_sites.R` on every push to `main` and commits
the updated HTML back. Let me know if you want that added — it's about
30 lines of YAML.

## Customizing

- **Project intro.** Edit the `# About This Project` section near the top of
  `site_report_template.Rmd` to change the 2–3 sentence blurb that appears on
  every site report.
- **Which sections go where.** The narrative ordering is just a series of
  top-level markdown headers in the Rmd — move them around freely.
- **Word-doc output.** The YAML already declares a `word_document` output.
  Render with `output_format = "word_document"` (though the Plotly widgets
  and the SVG model diagram only render in HTML).
- **Dropdown styling.** `docs/index.html` is self-contained; edit the CSS
  block at the top to match your project's colors.
