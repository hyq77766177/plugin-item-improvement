{FontAwesome} = window
remote = require 'remote'
windowManager = remote.require './lib/window'

path = require 'path-extra'
i18n = new(require 'i18n-2')
  locales: ['en-US', 'ja-JP', 'zh-CN']
  defaultLocale: 'zh-CN'
  directory: path.join(__dirname, "i18n")
  updateFiles: false
  indent: "\t"
  extension: '.json'
  devMode: false
i18n.setLocale(window.language)
__ = i18n.__.bind(i18n)

itemImprovementWindow = null
initialItemImprovementWindow = ->
  itemImprovementWindow = windowManager.createWindow
    x: config.get 'poi.window.x', 0
    y: config.get 'poi.window.y', 0
    width: 820
    height: 650
    realClose: true
  itemImprovementWindow.on 'close', ->
    itemImprovementWindow = null
  itemImprovementWindow.loadURL "file://#{__dirname}/index.html"

module.exports =
  name: 'Item-Improvement'
  priority: 50
  displayName: <span><FontAwesome name='wrench' key={0} /> {__ "Equipment Improvement"}</span>
  author: 'Dazzy Ding'
  link: 'https://github.com/yukixz'
  contributors: [{author: 'KochiyaOcean', link: 'https://github.com/kochiyaocean'}]
  version: '2.0.0'
  description: __ "Show possible improvements of the day"
  handleClick: ->
    if not itemImprovementWindow?
      initialItemImprovementWindow()
    itemImprovementWindow.show()
