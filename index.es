const {config} = window
export const windowOptions = {
  x: config.get ('poi.window.x', 0),
  y: config.get ('poi.window.y', 0),
  width: 820,
  height: 650,
}

export const windowURL = `file://${__dirname}/index.html`
export const realClose = true
