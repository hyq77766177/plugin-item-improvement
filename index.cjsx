{React, ReactBootstrap, FontAwesome} = window
{Button} = ReactBootstrap
remote = require 'remote'
windowManager = remote.require './lib/window'
i18n = require './node-modules/i18n'
{__} = i18n
path = require 'path-extra'
i18n.configure({
    locales:['en_US', 'ja_JP', 'zh_CN'],
    defaultLocale: 'zh_CN',
    directory: path.join(__dirname, "i18n"),
    updateFiles: false,
    indent: "\t",
    extension: '.json'
})
i18n.setLocale(window.language)

itemImprovementWindow = null
initialItemImprovementWindow = ->
  itemImprovementWindow = windowManager.createWindow
    # Use config
    realClose: true
    x: config.get 'poi.window.x', 0
    y: config.get 'poi.window.y', 0
    width: 820
    height: 650
  itemImprovementWindow.loadUrl "file://#{__dirname}/index.html"
  itemImprovementWindow.webContents.on 'dom-ready', (e)->
    itemImprovementWindow.show()

module.exports =
  name: 'Item-Improvement'
  priority: 50
  displayName: <span><FontAwesome name='wrench' key={0} /> {__ "Equipment Improvement"}</span>
  author: 'KochiyaOcean'
  link: 'https://github.com/kochiyaocean'
  version: '1.3.0'
  description: __ "Show possible improvements of the day"
  handleClick: ->
    initialItemImprovementWindow()
