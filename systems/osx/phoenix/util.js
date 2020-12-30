function log(obj, msg = '') {
  Phoenix.log(`${msg}\n${JSON.stringify(obj, null, 2)}`);
}

function getWindowId(window) {
  return [window.app().name(), Screen.main().flippedVisibleFrame().width].join(
    '::',
  );
}

function isEqual(a, b) {
  return (
    Math.round(a.x / 10) === Math.round(b.x / 10) &&
    Math.round(a.y / 10) === Math.round(b.y / 10) &&
    Math.round(a.width / 10) === Math.round(b.width / 10) &&
    Math.round(a.height / 10) === Math.round(b.height / 10)
  );
}

function getScreenWithPad() {
  const fullScreen = Screen.main().flippedVisibleFrame();

  const screen = {
    x: fullScreen.x + PAD_X,
    y: fullScreen.y + PAD_Y,
    width: fullScreen.width - 2 * PAD_X,
    height: fullScreen.height - 2 * PAD_Y,
  };

  screen.leftHalf = {
    x: screen.x,
    y: screen.y,
    width: screen.width / 2 - PAD_X / 2,
    height: screen.height,
  };

  screen.leftThird = {
    x: screen.x,
    y: screen.y,
    width: screen.width / 3 - PAD_X / 2,
    height: screen.height,
  };

  screen.leftTwoThirds = {
    x: screen.x,
    y: screen.y,
    width: (screen.width / 3) * 2 - PAD_X / 2,
    height: screen.height,
  };

  screen.rightHalf = {
    x: screen.x + screen.width / 2 + PAD_X / 2,
    y: screen.y,
    width: screen.width / 2 - PAD_X / 2,
    height: screen.height,
  };

  screen.rightThird = {
    x: screen.x + (screen.width / 3) * 2 + PAD_X / 2,
    y: screen.y,
    width: screen.width / 3 - PAD_X / 2,
    height: screen.height,
  };

  screen.rightTwoThirds = {
    x: screen.x + screen.width / 3 + PAD_X / 2,
    y: screen.y,
    width: (screen.width / 3) * 2 - PAD_X / 2,
    height: screen.height,
  };

  return screen;
}

function getCurrentWindow() {
  const window = Window.focused();

  window.currentSize = {
    x: window.topLeft().x,
    y: window.topLeft().y,
    width: window.size().width,
    height: window.size().height,
  };

  return window;
}
