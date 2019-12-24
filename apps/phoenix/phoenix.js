#!/usr/bin/env ~/.config/phoenix/node_modules/.bin/babel

const PAD_X = 0
const PAD_Y = 0

const getScreenWithPad = () => {
    const fullScreen = Screen.main().flippedVisibleFrame();

    return {
        x: fullScreen.x + PAD_X,
        y: fullScreen.y + PAD_Y,
        width: fullScreen.width - (2 * PAD_X),
        height: fullScreen.height - (2 * PAD_Y),
    }
}

const sizeFraction = (widthPct, width, heightPct, height) => {
    return {
        width: (width * widthPct) - (PAD_X * widthPct),
        height: (height * heightPct) - (PAD_Y * heightPct),
    }
}

Key.on('h', ['cmd', 'shift'], () => {
    const screen = getScreenWithPad()
    const window = Window.focused();

    const half = {
        x: screen.x,
        y: screen.y,
        width: (screen.width / 2) - (PAD_X / 2),
        height: screen.height,
    }

    const oneThird = {
        x: screen.x,
        y: screen.y,
        width: (screen.width / 3) - (PAD_X / 2),
        height: screen.height,
    }

    const twoThirds = {
        x: screen.x,
        y: screen.y,
        width: (screen.width / 3 * 2) - (PAD_X / 2),
        height: screen.height,
    }

    if (window) {
        const current = {
            x: window.topLeft().x,
            y: window.topLeft().y,
            width: window.size().width,
            height: window.size().height,
        }

        if (isEqual(current, half)) {
            window.setFrame(oneThird)
        } else if (isEqual(current, oneThird)) {
            window.setFrame(twoThirds)
        } else {
            window.setFrame(half)
        }
    }
});

const isEqual = (a, b) =>
    Math.round(a.x / 10) === Math.round(b.x / 10) &&
    Math.round(a.y / 10) === Math.round(b.y / 10) &&
    Math.round(a.width / 10) === Math.round(b.width / 10) &&
    Math.round(a.height / 10) === Math.round(b.height / 10)

Key.on('l', ['cmd', 'shift'], () => {
    const window = Window.focused();
    const screen = getScreenWithPad()

    const half = {
        x: screen.x + (screen.width / 2) + (PAD_X / 2),
        y: screen.y,
        width: (screen.width / 2) - (PAD_X / 2),
        height: screen.height,
    }

    const oneThird = {
        x: screen.x + (screen.width / 3 * 2) + (PAD_X / 2),
        y: screen.y,
        width: (screen.width / 3) - (PAD_X / 2),
        height: screen.height,
    }

    const twoThirds = {
        x: screen.x + (screen.width / 3) + (PAD_X / 2),
        y: screen.y,
        width: (screen.width / 3 * 2) - (PAD_X / 2),
        height: screen.height,
    }

    if (window) {
        const current = {
            x: window.topLeft().x,
            y: window.topLeft().y,
            width: window.size().width,
            height: window.size().height,
        }

        if (isEqual(current, half)) {
            window.setFrame(oneThird)
        } else if (isEqual(current, oneThird)) {
            window.setFrame(twoThirds)
        } else {
            window.setFrame(half)
        }
    }
});

Key.on('j', ['cmd', 'shift'], () => {
    const window = Window.focused();
    const screen = getScreenWithPad()

    if (window) {
        window.setFrame({
            x: window.topLeft().x,
            y: screen.y + (screen.height / 2) + (PAD_Y / 2),
            width: window.size().width,
            height: (screen.height / 2) - (PAD_Y / 2) - 1,
        });
    }
});

Key.on('k', ['cmd', 'shift'], () => {
    const window = Window.focused();
    const screen = getScreenWithPad()

    if (window) {
        window.setFrame({
            x: window.topLeft().x,
            y: screen.y,
            width: window.size().width,
            height: (screen.height / 2) - (PAD_Y / 2) - 1,
        });
    }
});

Key.on('m', ['cmd', 'shift'], () => {
    const window = Window.focused();
    const screen = getScreenWithPad()

    if (window) {
        window.setFrame(screen)
    }
});

const getWindowId = window => `${window.app().name()}::${window.title()}`

Key.on(',', ['cmd', 'shift'], () => {
    const window = Window.focused();
    const windowId = getWindowId(window)

    if (windowId) {
        const frame = Storage.get(windowId)
        if (frame) {
            window.setFrame(frame)
        }
    }
});

// Key.on('o', [ 'option' ], () => {
// const app = App.get('Google Chrome')
// app.windows().find(w => w.title().startsWith('Google Hangouts')).focus()
// });

// Key.on('e', [ 'option' ], () => {
// const app = App.get('Google Chrome')
// app.windows().find(w => w.title().endsWith('Google Chrome')).focus()
// });

Key.on('i', ['cmd', 'shift'], () => {
    const window = Window.focused()
    const screen = getScreenWithPad()
    const windowId = getWindowId(window)

    const text = `
        id: ${windowId}
        screen: x: ${screen.x} y: ${screen.y} w: ${screen.width} h: ${screen.height}
        window: x: ${window.topLeft().x} y: ${window.topLeft().y} w: ${window.size().width} h: ${window.size().height}
    `.split('\n').map(s => s.trim()).join('\n')

    const m = Modal.build({
        text,
        origin: frame => {
            return {
                x: (screen.width / 2) - (frame.width / 2),
                y: (screen.height / 2) - (frame.height / 2),
            }
        },
        appearance: 'dark',
        weight: 14,
    })

    const ids = []

    ids.push(Key.on('escape', [], () => {
        m.close()
        ids.forEach(id => Key.off(id))
    }))

    ids.push(Key.on('s', [], () => {
        const frame = {
            ...window.size(),
            ...window.topLeft(),
        }
        Storage.set(windowId, frame)
        m.text = 'Saved!'
        setTimeout(() => m.close(), 500)
        ids.forEach(id => Key.off(id))
    }))

    ids.push(Key.on('x', [], () => {
        Storage.remove(windowId)
        m.text = 'Cleared'
        setTimeout(() => m.close(), 500)
        ids.forEach(id => Key.off(id))
    }))

    m.show()
});
