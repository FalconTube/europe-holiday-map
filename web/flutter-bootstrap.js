{
  {
    flutter_js;
  }
}
{
  {
    flutter_build_config;
  }
}

// TODO: Replace this with your own code to determine which renderer to use.
const useCanvasKit = false;

const config = {
  renderer: useCanvasKit ? "canvaskit" : "skwasm",
};
_flutter.loader.load({
  config: config,
});
