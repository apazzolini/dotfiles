#!/usr/bin/env ~/.config/phoenix/node_modules/.bin/babel

require('./util.js');

const PAD_X = 0;
const PAD_Y = 0;

Key.on('h', ['cmd', 'shift'], () => {
  const screen = getScreenWithPad();
  const window = getCurrentWindow();

  if (window) {
    if (isEqual(window.currentSize, screen.leftHalf)) {
      window.setFrame(screen.leftTwoThirds);
    } else if (isEqual(window.currentSize, screen.leftTwoThirds)) {
      window.setFrame(screen.leftThird);
    } else {
      window.setFrame(screen.leftHalf);
    }
  }
});

Key.on('l', ['cmd', 'shift'], () => {
  const screen = getScreenWithPad();
  const window = getCurrentWindow();

  if (window) {
    if (isEqual(window.currentSize, screen.rightHalf)) {
      window.setFrame(screen.rightTwoThirds);
    } else if (isEqual(window.currentSize, screen.rightTwoThirds)) {
      window.setFrame(screen.rightThird);
    } else {
      window.setFrame(screen.rightHalf);
    }
  }
});

Key.on('j', ['cmd', 'shift'], () => {
  const window = getCurrentWindow();
  const screen = getScreenWithPad();

  if (window) {
    window.setFrame({
      x: window.topLeft().x,
      y: screen.y + screen.height / 2 + PAD_Y / 2,
      width: window.size().width,
      height: screen.height / 2 - PAD_Y / 2 - 1,
    });
  }
});

Key.on('k', ['cmd', 'shift'], () => {
  const window = getCurrentWindow();
  const screen = getScreenWithPad();

  if (window) {
    window.setFrame({
      x: window.topLeft().x,
      y: screen.y,
      width: window.size().width,
      height: screen.height / 2 - PAD_Y / 2 - 1,
    });
  }
});

Key.on('m', ['cmd', 'shift'], () => {
  const window = Window.focused();
  const screen = getScreenWithPad();

  if (window) {
    window.setFrame(screen);
  }
});

Key.on(',', ['cmd', 'shift'], () => {
  const window = Window.focused();
  const windowId = getWindowId(window);

  if (windowId) {
    const frame = Storage.get(windowId);
    if (frame) {
      window.setFrame(frame);
    }
  }
});

Key.on('i', ['cmd', 'shift'], () => {
  const window = Window.focused();
  const screen = getScreenWithPad();
  const windowId = getWindowId(window);
  const topLeft = window.topLeft();
  const size = window.size();

  const text = `
    id: ${windowId}
    screen: x: ${screen.x} y: ${screen.y} w: ${screen.width} h: ${screen.height}
    window: x: ${topLeft.x} y: ${topLeft.y} w: ${size.width} h: ${size.height}
  `
    .split('\n')
    .map(s => s.trim())
    .join('\n');

  const m = Modal.build({
    text,
    origin: frame => {
      return {
        x: screen.width / 2 - frame.width / 2,
        y: screen.height / 2 - frame.height / 2,
      };
    },
    appearance: 'dark',
    weight: 14,
  });

  const ids = [];

  ids.push(
    Key.on('escape', [], () => {
      m.close();
      ids.forEach(id => Key.off(id));
    }),
  );

  ids.push(
    Key.on('s', [], () => {
      const frame = {
        ...window.size(),
        ...window.topLeft(),
      };
      Storage.set(windowId, frame);
      m.text = 'Saved!';
      setTimeout(() => m.close(), 500);
      ids.forEach(id => Key.off(id));
    }),
  );

  ids.push(
    Key.on('x', [], () => {
      Storage.remove(windowId);
      m.text = 'Cleared';
      setTimeout(() => m.close(), 500);
      ids.forEach(id => Key.off(id));
    }),
  );

  m.show();
});
