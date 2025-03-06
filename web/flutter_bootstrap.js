
{{flutter_js}}
{{flutter_build_config}}

console.log("hi");
const useCanvasKit = true;

const config = {
  renderer: useCanvasKit ? "canvaskit" : "skwasm",
};
_flutter.loader.load({
  config: config,
});

