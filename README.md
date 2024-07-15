# Deploy Shinylive R App on Github Pages

Based on this [tutorial](https://medium.com/@rami.krispin/deploy-shiny-app-on-github-pages-b4cbd433bdc).

For deployment:

```r
shinylive::export(appdir = "glittr-stats", destdir = "docs")
httpuv::runStaticServer("docs/", port=8008)
```