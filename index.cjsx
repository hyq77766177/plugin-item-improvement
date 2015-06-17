{React, ReactBootstrap, FontAwesome} = window
{Button} = ReactBootstrap
remote = require 'remote'
windowManager = remote.require './lib/window'

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
  displayName: [<FontAwesome name='wrench' key={0} />, ' 装备改修']
  author: 'KochiyaOcean'
  link: 'https://github.com/kochiyaocean'
  version: '1.2.1-20150605'
  description: '查看装备改修信息'
  handleClick: ->
    initialItemImprovementWindow()
