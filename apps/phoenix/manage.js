const wins = {
    'a-1': 'a-2',
    'a-2': 'a-1',
    'b-1': 'b-2',
    'b-2': 'b-1',
}

const cmdTilde = new Key('`', ['cmd'], () => {
    const window = Window.focused();
    const altWindow = wins[window.title()]

    window.app().windows().find(w => w.title() === altWindow).focus()
})
cmdTilde.disable()

Event.on('appDidActivate', app => {
    if (app.name() === 'iTerm2') {
        cmdTilde.enable()
    } else {
        cmdTilde.disable()
    }
    Phoenix.log('enabled', app.name(), cmdTilde.isEnabled())
})


Key.on('i', [ 'cmd', 'shift' ], () => {
    const window = Window.focused();
    const screen = getScreenWithPad()
    const app = window.app()
    Phoenix.log('hi')

    let charCode = 97

    const appWindows = app.windows().sort((a, b) => a.title().localeCompare(b.title())).map(w => ({
        code: String.fromCharCode(charCode++),
        title: w.title(),
        window: w,
    }))

    const text = `
        ${appWindows.map(w => `${w.code}: ${w.title}`).join('\n')}
    `.split('\n').map(s => s.trim()).join('\n')

    const m = Modal.build({
        text,
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

    const dereg = appWindows.map(w => {
        return Key.on(w.code, [], () => {
            appWindows.find(w2 => w.code === w2.code).window.focus()
            dereg.forEach(id => Key.off(id))
            m.close()
        })
    })
});

