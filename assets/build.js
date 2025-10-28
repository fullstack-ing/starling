import * as esbuild from "esbuild";
import { transform, bundleAsync } from "lightningcss";
import { fileURLToPath } from "url";
import { dirname, resolve } from "path";
import { readFileSync, writeFileSync, watch as fsWatch } from "fs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const args = process.argv.slice(2);
const watch = args.includes("--watch");
const deploy = args.includes("--deploy");

const loader = {
  ".svg": "file",
  ".png": "file",
  ".jpg": "file",
  ".jpeg": "file",
  ".gif": "file",
  ".woff": "file",
  ".woff2": "file",
  ".ttf": "file",
  ".eot": "file",
};

const plugins = [
  {
    name: "phoenix-live-reload",
    setup(build) {
      build.onEnd((result) => {
        if (result.errors.length > 0) {
          console.error("Build failed:", result.errors);
        } else if (watch) {
          console.log("Build complete ✓");
        }
      });
    },
  },
];

const config = {
  entryPoints: ["js/app.js"],
  bundle: true,
  target: "es2022",
  outdir: resolve(__dirname, "../priv/static/assets/js"),
  logLevel: "info",
  loader,
  plugins,
  sourcemap: deploy ? false : (watch ? "inline" : "external"),
  minify: deploy,
  define: {
    "process.env.NODE_ENV": deploy ? '"production"' : '"development"',
  },
  external: ["/fonts/*", "/images/*"],
};

// CSS build function
async function buildCSS() {
  try {
    const { code, map } = await bundleAsync({
      filename: resolve(__dirname, "css/app.css"),
      minify: deploy,
      sourceMap: !deploy,
      targets: {
        chrome: 90,
        firefox: 88,
        safari: 14,
      },
    });

    const outPath = resolve(__dirname, "../priv/static/assets/css/app.css");

    // Write CSS file
    writeFileSync(outPath, code);

    // Write source map in development
    if (!deploy && map) {
      writeFileSync(outPath + ".map", map.toString());
    }

    if (watch) {
      console.log("CSS build complete ✓");
    }
  } catch (error) {
    console.error("CSS build failed:", error);
  }
}

// Build both JS and CSS
if (watch) {
  // Build CSS initially
  await buildCSS();

  // Watch CSS files
  fsWatch(
    resolve(__dirname, "css"),
    { recursive: true },
    (eventType, filename) => {
      if (filename?.endsWith(".css")) {
        buildCSS();
      }
    }
  );

  // Watch JS files
  const ctx = await esbuild.context(config);
  await ctx.watch();
  console.log("Watching for changes...");
} else {
  // Build both for production
  await Promise.all([
    esbuild.build(config),
    buildCSS(),
  ]);
}
