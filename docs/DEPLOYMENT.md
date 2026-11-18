# Deploy to shinyapps.io

1. Run both R test scripts from the repository root.
2. Install `rsconnect` and log into your own shinyapps.io dashboard. In Account → Tokens, copy its setup command into your local R console only. Do not save it in a script, screenshot or Git commit.
3. Update the account argument in `scripts/deploy.R` if using an account other than `peppermint`.
4. Run `source('scripts/deploy.R')`. For an existing app, use its `appId` to avoid creating a second app. The initial app ID for this project is 18472741.
5. Open the returned URL, change a scenario, check the scale result, and click Reset to workbook baseline. Check narrow-screen usability and source links.

Only app.R, R/model.R, models.csv, baseline.csv and www/style.css are uploaded. No raw Excel files or private credentials are required by the app.

GitHub publishing, if a local authenticated Git client is configured:

```sh
git init -b main
git add .
git commit -m "Add validated DeepSeek inference economics dashboard"
git remote add origin https://github.com/ybiyuean-del/deepseek-inference-economics.git
git push -u origin main
```

For a repository that already has commits, clone it first and copy the project files into the checkout rather than overwriting its history. Repository visibility is managed separately in GitHub Settings → General → Danger Zone → Change repository visibility.
