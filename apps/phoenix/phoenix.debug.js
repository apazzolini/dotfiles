#!/usr/bin/env /Users/Andre/.config/phoenix/node_modules/.bin/babel

// const isEqual = require('node_modules/lodash/isEqual.js')

const PAD_X = 8
const PAD_Y = 6

const log = (obj, msg = '') => {
    Phoenix.log(`${msg}\n${JSON.stringify(obj, null, 2)}`)
}

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

Key.on('h', [ 'cmd', 'shift' ], () => {
    const screen = getScreenWithPad()
    const window = Window.focused();
    // log(window.topLeft())

    const m = Modal.build({
        text: 'a: abc\nb: def',
        origin: frame => {
            const winPos = window.topLeft()
            const winSize = window.size()

            // log(screen, 'screen')
            // log(frame, 'frame')
            // log({ winPos, winSize }, 'win')

            return {
                x: ((winPos.x + winSize.width) / 2) - (frame.width / 2),
                y: screen.height - frame.height + PAD_Y,
            }
        },
        appearance: 'dark',
        duration: 5,
        weight: 12,
    })

    m.show()

    // Key.once('a', [], () => {
        // const m2 = Modal.build({
            // text: 'pressed a',
            // origin: frame => {
                // const winPos = window.topLeft()
                // const winSize = window.size()

                // // log(screen, 'screen')
                // // log(frame, 'frame')
                // // log({ winPos, winSize }, 'win')

                // return {
                    // x: ((winPos.x + winSize.width) / 2) - (frame.width / 2),
                    // y: screen.height - frame.height + PAD_Y - 300,
                // }
            // },
            // appearance: 'dark',
            // duration: 5,
        // })

        // m2.show()
    // })
        //
        window.app().windows().forEach(w => {
            log({ size: w.size(), pos: w.topLeft() })
        })

    const half = {
        x: screen.x,
        y: screen.y,
        ...sizeFraction(0.5, screen.width, 1.0, screen.height)
    }

    const third = {
        x: screen.x,
        y: screen.y,
        ...sizeFraction(0.5, screen.width, 1.0, screen.height)
    }

    if (window) {
        window.setFrame(half);
    }
});

Key.on('l', [ 'cmd', 'shift' ], () => {
    const window = Window.focused();
    const screen = getScreenWithPad()

    if (window) {
        window.setFrame({
            x: screen.x + (screen.width / 2) + (PAD_Y / 2),
            y: screen.y,
            ...sizeFraction(0.5, screen.width, 1.0, screen.height)
        });
    }
});

Key.on('j', [ 'cmd', 'shift' ], () => {
    const window = Window.focused();
    const screen = getScreenWithPad()

    if (window) {
        window.setFrame({
            x: screen.x + (screen.width / 2) + (PAD_Y / 2),
            y: screen.y,
            ...sizeFraction(0.5, screen.width, 1.0, screen.height)
        });
    }
});
